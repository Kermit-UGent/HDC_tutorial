include("hdc_tutorial.jl")


# EXAMPLE: AMINO ACIDS


bundle(hvs) = sign.(sum(hvs))


amino_acids_properties = Dict(
    # Nonpolar
    'G' => (group=:nonpolar, structure=:aliphatic, charge=:neutral, size=:tiny),
    'A' => (group=:nonpolar, structure=:aliphatic, charge=:neutral, size=:tiny),
    'V' => (group=:nonpolar, structure=:aliphatic_branched, charge=:neutral, size=:medium),
    'L' => (group=:nonpolar, structure=:aliphatic_branched, charge=:neutral, size=:medium),
    'I' => (group=:nonpolar, structure=:aliphatic_branched, charge=:neutral, size=:medium),
    'P' => (group=:nonpolar, structure=:aliphatic_cyclic, charge=:neutral, size=:small),
    'M' => (group=:nonpolar, structure=:sulfur, charge=:neutral, size=:medium),
    'F' => (group=:nonpolar, structure=:aromatic, charge=:neutral, size=:bulky),
    'W' => (group=:nonpolar, structure=:aromatic, charge=:neutral, size=:bulky),

    # Polar (Uncharged)
    'S' => (group=:polar, structure=:hydroxyl, charge=:neutral, size=:small),
    'T' => (group=:polar, structure=:hydroxyl, charge=:neutral, size=:small),
    'C' => (group=:polar, structure=:sulfur_thiol, charge=:neutral, size=:small),
    'Y' => (group=:polar, structure=:aromatic_phenolic, charge=:neutral, size=:bulky),
    'N' => (group=:polar, structure=:amide, charge=:neutral, size=:small),
    'Q' => (group=:polar, structure=:amide, charge=:neutral, size=:medium),

    # Acidic (Charged)
    'D' => (group=:acidic, structure=:carboxyl, charge=:negative, size=:small),
    'E' => (group=:acidic, structure=:carboxyl, charge=:negative, size=:medium),

    # Basic (Charged)
    'K' => (group=:basic, structure=:amine, charge=:positive, size=:medium),
    'R' => (group=:basic, structure=:guanidino, charge=:positive, size=:bulky),
    'H' => (group=:basic, structure=:imidazole, charge=:positive, size=:medium)
)

aa_properties = union(values(amino_acids_properties)...)

amino_acids = collect(keys(amino_acids_properties)) |> sort!

aa_sizes = union(proptup.size for proptup in values(amino_acids_properties))

aa_properties_hvs = Dict(prop => hv(N) for prop in aa_properties)

aa_properties_hvs[:small] = flip(aa_properties_hvs[:tiny], 0.25)
aa_properties_hvs[:medium] = flip(aa_properties_hvs[:small], 0.25)
aa_properties_hvs[:bulky] = flip(aa_properties_hvs[:medium], 0.25)

size_sim = [sim(aa_properties_hvs[s1], aa_properties_hvs[s2]) for s1 in [:tiny, :small, :medium, :bulky],
            s2 in [:tiny, :small, :medium, :bulky]]


aa_hvs = Dict(aa => bundle((aa_properties_hvs[p] for p in props) ∪ [hv(N)]) for (aa, props) in amino_acids_properties)

sim_aa = [sim(aa_hvs[aa1], aa_hvs[aa2]) for aa1 in amino_acids, aa2 in amino_acids]

heatmap(amino_acids, amino_acids, sim_aa)

v_positive = aa_properties_hvs[:positive]
v_negative = aa_properties_hvs[:negative]

histone = "MSGRGKGGKGLGKGGAKRHRKVLRDNIQGITKPAIRRLARRGGVKRISGLIYEETRGVLKVFLENVIRDAVTYTEHAKRKTVTAMDVVYALKRQGRTLYGFGG"
myoglobine = "MGLSDGEWQLVLNVWGKVEADIPGHGQEVLIRLFKGHPETLEKFDKFKHLKSEDEMKASEDLKKHGATVLTALGGILKKKGHHEAEIKPLAQSHATKHKIPVKYLEFISECIIQVLQSKHPGDFGADAEGAMNKALELFRKDMASNYKELGFQG"

sequence = histone

v_histone = sign.(sum(aa_hvs[aa] for aa in histone))
v_myoglobine = sign.(sum(aa_hvs[aa] for aa in myoglobine))

sim(v_histone, v_myoglobine)

aa_match = [(sim(v_histone, v_aa), aa) for (aa, v_aa) in aa_hvs] |> sort! |> reverse!

sim(v_histone, v_positive)
sim(v_histone, v_negative)

sim(v_myoglobine, v_positive)
sim(v_myoglobine, v_negative)
