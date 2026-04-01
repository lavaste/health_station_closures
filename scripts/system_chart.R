

# Finnish Patient Pathway 2013–2019
# Three tiers: public, private, and occupational primary care
# + public and private specialised care
# Uses DiagrammeR (Graphviz DOT engine)

library(DiagrammeR)

pdf(here::here("output", tag, "system_graph.pdf"))

system_chart <- grViz("
digraph patient_pathway {

  # ── Global graph settings ──────────────────────────────────────
  graph [
    rankdir     = TB,
    fontname = 'Times New Roman',
    splines     = spline,
    nodesep     = 0.1,
    ranksep     = 0.7,
    label       = 'Patient Pathways and Distribution of Visits Among the Elderly Population',
    labelloc    = t,
    labeljust   = l,
    fontsize    = 15,
    center      = true]

  # ── Default node style ─────────────────────────────────────────
  node [
    shape     = rectangle,
    style     = 'filled,rounded'
    fontname = 'Times New Roman',
    fontsize  = 11,
    fixedsize = true,
    width     = 2.2,
    penwidth  = 0.8]

  # ── Default edge style ─────────────────────────────────────────
  edge [
    fontname = 'Times New Roman',
    fontsize  = 9,
    penwidth  = 2.5,
    arrowsize = 0.7]

  # ══════════════════════════════════════════════════════════════
  # NODES
  # ══════════════════════════════════════════════════════════════

  # ── Entry point (patient) ─────────────────────────────────────────
  
  subgraph cluster_patient {
  style    = invis    # no border, no fill — purely for layout
  patient [
    label     = 'Patient',
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

  # ── Primary care tier ─────────────────────────────────────────

  # ── Tier 1 cluster ─────────────────────────────────────
  
  subgraph cluster_primary {
    label = 'Primary care'
    labelloc = t
    labeljust = l
    fontsize = 18
    fontname = 'Times New Roman'
    penwidth = 1
    color = '#BEBEBE'
    style = dashed
    bgcolor = '#F5F5F5'
    
  public_primary [
    label     = 'PUBLIC\n(93%)\n\nProvided mostly in public health stations/centres.\nFor all citizens.\nLow fees.\nLong waiting times.',
    fillcolor = '#A8D8C4',
    color     = '#2E8B6A',
    fontcolor = '#163126',
    fontname = 'Times New Roman',
    height    = 2.2,
    width     = 4.4]

  private_primary [
    label     = 'PRIVATE\n(6%)\n\nProvided in\nprivate clinics.\nHigh fees.\nFor everyone who\ncan afford it.\nMinimal waiting\ntimes.',
    fillcolor = '#A8CFEE',
    color     = '#2A72B5',
    fontcolor = '#133F62',
    fontname = 'Times New Roman',
    height    = 2.2,
    width     = 1.5]

  occupational [
    label     = 'OCCUPATIONAL\n(1%)\n\nProvided mainly\nin private clinics.\nOnly for the\nemployed.\nNo fees.\nMinimal waiting\ntimes.',
    fillcolor = '#E8E0F4',
    color     = '#6A4BBD',
    fontcolor = '#3E2880',
    fontname = 'Times New Roman',
    height    = 2.2,
    width     = 1.3]
  
  { rank = same; public_primary; private_primary; occupational }}

  # ── Specialised care tier ─────────────────────────────────────
  
  # ── Tier 2 cluster ─────────────────────────────────────
  subgraph cluster_specialised {
    label = 'Specialised care'
    labelloc = t
    labeljust = l
    fontsize = 18
    fontname = 'Times New Roman'
    color = '#BEBEBE'
    penwidth = 1
    style = dashed
    bgcolor = '#F5F5F5'
    
  public_specialised [
    label     = 'PUBLIC\n(94%)\n\nProvided mostly in publicly-owned hospitals.\nFor all citizens.\nLow fees.\nLong waiting times.',
    fillcolor = '#D5EDE4',
    color     = '#2E8B6A',
    fontcolor = '#1A5C44',
    fontname = 'Times New Roman',
    height    = 2.2,
    width     = 5.8]

  private_specialised [
    label     = 'PRIVATE\n(6%)\n\nSame characteristics\nas private primary care.\nGP referral not\nalways neccessary.',
    fillcolor = '#D0E8F8',
    color     = '#2A72B5',
    fontcolor = '#1A4A78',
    fontname = 'Times New Roman',
    height    = 2.2,
    width     = 1.5]
   
   # Keep specialised-care nodes on the same rank
  { rank = same; public_specialised; private_specialised}}


  # ══════════════════════════════════════════════════════════════
  # EDGES
  # ══════════════════════════════════════════════════════════════

  # Patient → primary care (free choice)
  patient:s -> public_primary:n    [color = '#888888', style = dashed]
  patient:s -> private_primary:n   [color = '#888888', style = dashed]
  patient:s -> occupational:n      [color = '#888888', style = dashed]

  # Public primary → public specialised
  # (requires GP referral; patients cannot self-refer)
  public_primary -> public_specialised [
    label    = 'GP referral',
    color    = '#2E8B6A',
    fontcolor = '#2E8B6A',
    style    = solid]

  # Private primary → public specialised
  # (referral also required for public hospital)
  private_primary:s -> public_specialised:n [
    taillabel    = '\n\nGP referral',
    color    = '#2A72B5',
    fontcolor = '#2A72B5',
    style    = solid]

  # Private primary → private specialised
  # (no referral required; direct access)
  private_primary:s -> private_specialised [
    taillabel    = '\n\n\nDirect access',
    color    = '#2A72B5',
    fontcolor = '#2A72B5',
    style    = dashed]

  # Occupational care → primary specialised
  # GP referral required
  occupational:s -> public_specialised [
    color     = '#6A4BBD',
    fontcolor = '#4D329F',
    style     = solid
  ]

# Occupational care → primary specialised
  # GP referral required
  occupational -> private_specialised[
    label     = 'GP referral',
    color     = '#6A4BBD',
    fontcolor = '#4D329F',
    style     = solid
  ]
  
  }")

dev.off()

print(system_chart)

# Aiempi väri occupational care #6A4BBD
