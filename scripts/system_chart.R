
#----------------------------------------------------------
# GET THL SERVICE USE TABLES
#----------------------------------------------------------

#---Get data to calculate shares from thl sampo------------
thl_hilmo_base_url <- "https://sampo.thl.fi/pivot/prod/fi/hilmokokonaisuus/kuutio01/fact_hilmokok_kuutio01"
thl_measure_filter <- "filter=measure-87578&filter=aika-660839&"
thl_age_older_filter <- "column=ikaluokka-110072&"

#----------Create functions------------------------------

read_thl_hilmo_table <- function(query) {
  readr::read_delim(
    file = paste0(thl_hilmo_base_url, ".csv?", query),
    delim = ";",
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA"),
    show_col_types = FALSE
  ) |>
    janitor::clean_names() |>
    dplyr::rename(visits = val) |>
    dplyr::mutate(
      visits = readr::parse_number(
        as.character(visits),
        locale = readr::locale(decimal_mark = ",", grouping_mark = " ")
      ))}

sum_selected_visits <- function(data, services, sector = NULL) {
  filtered_data <- data |>
    dplyr::filter(palvelu %in% services)

  if (!is.null(sector)) {
    filtered_data <- filtered_data |>
      dplyr::filter(palvelusektori == sector)}

  filtered_data |>
    dplyr::summarise(visits = sum(visits, na.rm = TRUE)) |>
    dplyr::pull(visits)}

format_pct <- function(x, digits = 0) {
  paste0(format(round(100 * x, digits), nsmall = digits, trim = TRUE), "%")}

#------------------Make tables--------------------
thl_hilmo_visits_older <- read_thl_hilmo_table(
  paste0(
    "row=palvelu-49937&row=palvelusektori-918725&",
    thl_age_older_filter,
    thl_measure_filter
  ))

thl_hilmo_primary_detail_older <- read_thl_hilmo_table(
  paste0(
    "row=palvelu-1131268&row=palvelusektori-918725&",
    thl_age_older_filter,
    thl_measure_filter
  ))

thl_hilmo_occupational_detail_older <- read_thl_hilmo_table(
  paste0(
    "row=palvelu-1131251&row=palvelusektori-918725&",
    thl_age_older_filter,
    thl_measure_filter
  ))

#----------------------------------------------------
# Muokkaa näitä palvelumuotovektoreita, jos haluat muuttaa osuuksien laskentaa
#  ---> poistetaan valitut palvelumuodot jos tarpeen
#  ---> jätetään esim. pth vain Avosairaanhoito?

selected_primary_services <- c(
  "Avosairaanhoito",
  "Ennaltaehkäisevät terveyspalvelut",
  "Kuntoutuspalvelut",
  "Mielenterveys- ja päihdepalvelut",
  "Suun terveydenhuolto",
  "Perusterveydenhuollon vuodeosastohoito",
  "Muut palvelumuodot")

selected_occupational_services <- c(
  "Ennaltaehkäisevä työterveyshuolto",
  "Sairaanhoito ja muu työterveyshuolto")

selected_specialised_services <- c(
  "Somaattinen erikoissairaanhoito",
  "Psykiatrinen erikoissairaanhoito")

#---------------------------------------------------
# Calculations: 
#---------------------------------------------------
# Pth: prosenttiosuudet -> pth käynneistä x% ei jatka esh (tälle oma boxi kuvaan)
# Esh kerroksessa 3 boxia (yht 100%) 
# - Tässä ainoa epäkohta se, että private esh osa ei tule pth kautta
#  -> % osuus on väärä, mutta ei varmasti iso osuus? selitteeseen että % osuudet on pth käynneistä?

public_primary_visits <- sum_selected_visits(
  data = thl_hilmo_primary_detail_older,
  services = selected_primary_services,
  sector = "Julkinen terveydenhuolto")

private_primary_visits <- sum_selected_visits(
  data = thl_hilmo_primary_detail_older,
  services = selected_primary_services,
  sector = "Yksityinen terveydenhuolto")

occupational_visits <- sum_selected_visits(
  data = thl_hilmo_occupational_detail_older,
  services = selected_occupational_services,
  sector = "Julkinen ja yksityinen yhteensä")

public_specialised_visits <- sum_selected_visits(
  data = thl_hilmo_visits_older,
  services = selected_specialised_services,
  sector = "Julkinen terveydenhuolto")

private_specialised_visits <- sum_selected_visits(
  data = thl_hilmo_visits_older,
  services = selected_specialised_services,
  sector = "Yksityinen terveydenhuolto")

primary_total_visits <- public_primary_visits + private_primary_visits + occupational_visits
specialised_total_visits <- public_specialised_visits + private_specialised_visits
no_specialised_visits <- primary_total_visits - specialised_total_visits

system_chart_share_data <- tibble::tibble(
  pathway = c(
    "public_primary",
    "private_primary",
    "occupational",
    "public_specialised",
    "private_specialised",
    "no_specialised"
  ),
  visits = c(
    public_primary_visits,
    private_primary_visits,
    occupational_visits,
    public_specialised_visits,
    private_specialised_visits,
    no_specialised_visits
  )
) |>
  dplyr::mutate(
    share_within_primary = dplyr::case_when(
      pathway %in% c("public_primary", "private_primary", "occupational") ~ visits / primary_total_visits,
      TRUE ~ NA_real_
    ),
    share_of_primary = visits / primary_total_visits,
    share_within_specialised = dplyr::case_when(
      pathway %in% c("public_specialised", "private_specialised") ~ visits / specialised_total_visits,
      TRUE ~ NA_real_
    ),
    share_within_specialised_layer = dplyr::case_when(
      pathway %in% c("public_specialised", "private_specialised", "no_specialised") ~ visits / primary_total_visits,
      TRUE ~ NA_real_
    )
  )

specialised_care_summary <- tibble::tibble(
  specialised_total_visits = specialised_total_visits,
  specialised_share_of_primary = specialised_total_visits / primary_total_visits,
  no_specialised_share_of_primary = no_specialised_visits / primary_total_visits,
  public_share_within_specialised = public_specialised_visits / specialised_total_visits,
  private_share_within_specialised = private_specialised_visits / specialised_total_visits,
  public_share_of_primary = public_specialised_visits / primary_total_visits,
  private_share_of_primary = private_specialised_visits / primary_total_visits
)

public_primary_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "public_primary") |>
  dplyr::pull(share_within_primary) |>
  format_pct()

private_primary_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "private_primary") |>
  dplyr::pull(share_within_primary) |>
  format_pct()

occupational_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "occupational") |>
  dplyr::pull(share_within_primary) |>
  format_pct()

public_specialised_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "public_specialised") |>
  dplyr::pull(share_within_specialised_layer) |>
  format_pct()

private_specialised_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "private_specialised") |>
  dplyr::pull(share_within_specialised_layer) |>
  format_pct()

# ESH layer now has three outcomes that sum to 100% of selected PTH visits.
no_specialised_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "no_specialised") |>
  dplyr::pull(share_within_specialised_layer) |>
  format_pct()

secondary_followup_pct_priv <- system_chart_share_data |>
  dplyr::filter(pathway == "private_specialised") |>
  dplyr::pull(share_of_primary) |>
  format_pct() 
secondary_followup_pct_pub <- system_chart_share_data |>
  dplyr::filter(pathway == "public_specialised") |>
  dplyr::pull(share_of_primary) |>
  format_pct()

no_secondary_followup_pct <- system_chart_share_data |>
  dplyr::filter(pathway == "no_specialised") |>
  dplyr::pull(share_of_primary) |>
  format_pct()
  

#---------------------------------------------------
# Create labels that are added to chart
#---------------------------------------------------

public_primary_label <- paste0(
  "PUBLIC\\n(",
  public_primary_pct,
  ")\\n\\nProvided mostly in public health stations/centres.\\nFor all citizens.\\nLow fees.\\nLong waiting times."
)

private_primary_label <- paste0(
  "PRIVATE\\n(",
  private_primary_pct,
  ")\\n\\nProvided in\\nprivate clinics.\\nHigh fees.\\nFor everyone who\\ncan afford it.\\nMinimal waiting\\ntimes."
)

occupational_label <- paste0(
  "OCCUPATIONAL\\n(",
  occupational_pct,
  ")\\n\\nProvided mainly\\nin private clinics.\\nOnly for the\\nemployed.\\nNo fees.\\nMinimal waiting\\ntimes."
)

public_specialised_label <- paste0(
  "PUBLIC\\n(",
  public_specialised_pct,
  ")\\n\\nProvided mostly in publicly-owned\\nhospitals.\\nFor all citizens.\\nLow fees.\\nLong waiting times."
)

private_specialised_label <- paste0(
  "PRIVATE\\n(",
  private_specialised_pct,
  ")\\n\\nSame characteristics\\nas private primary care.\\nGP referral not\\nalways necessary."
)

no_specialised_edge_label <- paste0(
  "NONE\\n(",
  no_secondary_followup_pct,
  ")"
)

#--------------------------------------------------
# DRAWING THE CHART
#--------------------------------------------------

# Finnish Patient Pathway 2013–2019
# Two tiers: public, private, and occupational primary care
# + public and private specialised care
# Uses DiagrammeR (Graphviz DOT engine)


library(DiagrammeR)
library(DiagrammeRsvg)
library(magrittr)
library(rsvg)


system_chart <- grViz(paste0("
digraph patient_pathway {

  // ── Global graph settings ──────────────────────────────────────
  graph [
    rankdir     = TB,
    fontname    = 'Times New Roman',
    splines     = spline,
    nodesep     = 0.1,
    ranksep     = 0.7,
    label       = <<b>Patient Pathways and Distribution of Visits Among the Elderly Population</b>>,
    labelloc    = t,
    labeljust   = l,
    fontsize    = 15,
    center      = true,
    compound    = true,
    ratio       = auto
  ]

  // ── Default node style ─────────────────────────────────────────
  node [
    shape     = rectangle,
    style     = 'filled,rounded',
    fontname  = 'Times New Roman',
    fontsize  = 11,
    fixedsize = true,
    width     = 2.2,
    penwidth  = 0.8
  ]

  // ── Default edge style ─────────────────────────────────────────
  edge [
    fontname  = 'Times New Roman',
    fontsize  = 9,
    penwidth  = 2.5,
    arrowsize = 0.7
  ]

  // ══════════════════════════════════════════════════════════════
  // NODES
  // ══════════════════════════════════════════════════════════════

  // ── Entry point (patient) ─────────────────────────────────────
  subgraph cluster_patient {
    style = invis
    
    patient [
      label     = 'Patient',
      shape     = rectangle,
      style     = 'rounded',
      color     = '#888888',
      fontcolor = '#333333',
      fontsize  = 13,
      fontname  = 'Times New Roman',
      width     = 2,
      height    = 0.5,
      fixedsize = true
    ]
  }

  // ── Primary care tier ─────────────────────────────────────────
  // ── Tier 1 cluster ────────────────────────────────────────────
  
  subgraph cluster_primary {
    label     = 'Primary care'
    labelloc  = t
    labeljust = l
    fontsize  = 18
    fontname  = 'Times New Roman'
    penwidth  = 1
    color     = '#BEBEBE'
    style     = 'rounded,dashed'
    bgcolor   = '#F5F5F5'

    public_primary [
      label     = '", public_primary_label, "',
      fillcolor = '#A8D8C4',
      color     = '#2E8B6A',
      fontcolor = '#163126',
      fontname  = 'Times New Roman',
      height    = 2.2,
      width     = 4.4
    ]

    private_primary [
      label     = '", private_primary_label, "',
      fillcolor = '#A8CFEE',
      color     = '#2A72B5',
      fontcolor = '#133F62',
      fontname  = 'Times New Roman',
      height    = 2.2,
      width     = 1.5
    ]

    occupational [
      label     = '", occupational_label, "',
      fillcolor = '#E8E0F4',
      color     = '#6A4BBD',
      fontcolor = '#3E2880',
      fontname  = 'Times New Roman',
      height    = 2.2,
      width     = 1.3
    ]

    { rank = same; public_primary; private_primary; occupational }
  }

  // ── Specialised care tier ─────────────────────────────────────
  // ── Tier 2 cluster ────────────────────────────────────────────
  
  subgraph cluster_specialised {
    label     = 'Specialised care'
    labelloc  = t
    labeljust = l
    fontsize  = 18
    fontname  = 'Times New Roman'
    color     = '#BEBEBE'
    penwidth  = 1
    style     = 'rounded,dashed'
    bgcolor   = '#F5F5F5'

    public_specialised [
      label     = '", public_specialised_label, "',
      fillcolor = '#D5EDE4',
      color     = '#2E8B6A',
      fontcolor = '#1A5C44',
      fontname  = 'Times New Roman',
      height    = 2.2,
      width     = 2.5
    ]

    private_specialised [
      label     = '", private_specialised_label, "',
      fillcolor = '#D0E8F8',
      color     = '#2A72B5',
      fontcolor = '#1A4A78',
      fontname  = 'Times New Roman',
      height    = 2.2,
      width     = 1.5
    ]

    not_specialised [
      label     = '", no_specialised_edge_label, "',
      shape     = rectangle,
      style     = 'rounded,dashed',
      color     = '#888888',
      width     = 4,
      height    = 2.2
    ]

    // Keep specialised-care nodes on the same rank
    { rank = same; public_specialised; private_specialised; not_specialised }
  }

  // ── Legend tier ───────────────────────────────────────────────
  
subgraph clusterLegend { 
    label = 'Legend'
    fontsize = 10
    style = 'invis'
    
    key [ 
      color = '#FFFFFF'
      label=<<table 
      border='0' 
      cellpadding='2'
      cellspacing='0'
      cellborder='0'>
      <tr><td align='right' port='i1'>A</td></tr>
      <tr><td align='right' port='i2'>A</td></tr>
      </table>> ]
    
    key2 [ 
      color = '#FFFFFF'
      label=<<table 
      border='0'
      cellpadding='2'
      cellspacing='0'
      cellborder='0'>
      <tr><td align='left' port='i1'>B</td><td>     GP referral</td></tr>
      <tr><td align='left' port='i2'>B</td><td>     Direct access</td></tr>
      </table>>]
    
    key:i1 -> key2:i1 [color = '#888888']
    
    key:i2 -> key2:i2 [ color = '#888888'
    style= dashed ]
   

  //keep legend near the bottom without blowing up the layout
    public_specialised -> key2[style = invis]
  
    {rank = same; key; key2}
  }

  // ══════════════════════════════════════════════════════════════
  // EDGES
  // ══════════════════════════════════════════════════════════════

  // Patient → primary care (free choice)
  patient -> public_primary:n    [color = '#888888', style = dashed]
  patient -> private_primary:n   [color = '#888888', style = dashed]
  patient -> occupational:n      [color = '#888888', style = dashed]
  patient -> private_specialised [color = '#888888', style = dashed]

  // Public primary → public specialised
  // requires GP referral; patients cannot self-refer
  public_primary -> public_specialised [
    color     = '#2E8B6A',
    fontcolor = '#2E8B6A',
    style     = solid
  ]

  // Private primary → public specialised
  // referral also required for public hospital
  private_primary:s -> public_specialised:n [
    color     = '#2A72B5',
    fontcolor = '#2A72B5',
    style     = solid
  ]

  // Private primary → private specialised
  // no referral required; direct access
  private_primary:s -> private_specialised [
    color     = '#2A72B5',
    fontcolor = '#2A72B5',
    style     = dashed
  ]

  // Occupational care → public specialised
  // GP referral required
  occupational:s -> public_specialised [
    color     = '#6A4BBD',
    fontcolor = '#4D329F',
    style     = solid
  ]

  // Occupational care → private specialised
  // GP referral required
  occupational -> private_specialised [
    color     = '#6A4BBD',
    fontcolor = '#4D329F',
    style     = solid
  ]
}
"))

system_chart

#------------------------------------------------
# Save charts
#------------------------------------------------
# Save as pdf
system_chart %>%
  export_svg %>% charToRaw %>% rsvg_pdf(file = here::here("output", tag, "system_graph.pdf"))

# Save as png
system_chart %>%
  export_svg() %>%
  charToRaw() %>%
  rsvg_png(file = here::here("output", tag, "system_graph.png"), 
           width = 2000)   # higher width = better resolution

# Empty saved values
rm(list = c(ls(pattern = "^thl_"), ls(pattern = "^selected_"), ls(pattern = "_visits$"), ls(pattern = "_pct$"), 
            ls(pattern = "_label$"), ls(pattern = "^secondary_"), "system_chart_share_data", "specialised_care_summary"))

