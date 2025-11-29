using DataFrames
using CSV
using Random
using LinearAlgebra
using DelimitedFiles

#include("scripts/hdc_tutorial.jl")

n = 250 # random subselection

sequences_data = DataFrame(CSV.File("data/sequences.csv"))
embeddings_data = DataFrame(CSV.File("data/embeddings.csv"))

X_emb = embeddings_data[!, 2:end] |> Matrix


labels = sequences_data.origin
bacterial_indices = findall(isequal("bacterial"), labels)
plant_indices = findall(!isequal("bacterial"), labels)

# select subset for each class
bacterial_indices = randsubseq(bacterial_indices, n / length(bacterial_indices))
plant_indices = randsubseq(plant_indices, n / length(plant_indices))

indices = vcat(bacterial_indices, plant_indices)
y = [i ∈ bacterial_indices for i in indices]

sequences = sequences_data.sequence[indices]
X_emb = X_emb[indices, :]
# round to save place
X_emb = round.(1000X_emb, digits=3)


# store subsets
open("data/TMD_simplified/embeddings.txt", "w") do io
    writedlm(io, X_emb)
end

open("data/TMD_simplified/sequences.txt", "w") do io
    writedlm(io, sequences)
end

open("data/TMD_simplified/labels.txt", "w") do io
    writedlm(io, y)
end

S = randn(size(X_emb, 2), 10_000)
H = sign.(X_emb * S)

v_bact = sum(H[y, :], dims=1) .|> sign
v_plant = sum(H[.!y, :], dims=1) .|> sign

dot(v_bact, v_plant) / norm(v_bact) / norm(v_plant)