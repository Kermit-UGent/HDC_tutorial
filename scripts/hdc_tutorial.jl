#=
Basic introduction to high-dimensions
=#

using LinearAlgebra, Plots, Random, Statistics

# UNDERSTANDING HIGH DIMENSIONS

# 1. Understanding the difference between low and high-dimensional

# change this to 100, 1000
n = 10

randvector(n) = randn(n)

vec1 = randvector(n)

vec2 = randvector(n)

norm(vec1)

norm(vec2)

norm(vec1 .- vec2)

dot(vec1, vec2)

dot(vec1, vec2) / (norm(vec1) * norm(vec2))

sim(u, v) = dot(u, v) / norm(u) / norm(v)

sim(v) = u -> sim(u, v)

sim(vec1, vec2)

vectors = [randvector(n) for i in 1:100]

histogram(norm.(vectors))

similarities_vectors = [sim(v1, v2) for v1 in vectors, v2 in vectors]

heatmap(similarities_vectors)

xs = [x for (x, y, z) in vectors]
ys = [y for (x, y, z) in vectors]
zs = [z for (x, y, z) in vectors]

scatter3d(xs, ys, zs)

sim_with_vector1 = [sim(vec1, v) for v in vectors]

minimum(sim_with_vector1)

maximum(sim_with_vector1)

histogram(sim_with_vector1, xlims=(-1, 1))



# 2. Hypervectors

N = 10_000

hv(N::Int=N) = rand((-1, 1), N)

u = hv()

v = hv()

sim(u, v)

similarities_hypervectors = [sim(u, hv()) for i in 1:10000]

histogram(similarities_hypervectors)

mean(similarities_hypervectors)

std(similarities_hypervectors)

# version to hash objects
hv(concept, N::Int=N) = rand(Random.MersenneTwister(hash(concept)), (-1, 1), N)

v_hi = hv("hi!")

hv("hi!")

v_goodbye = hv("goodbye...")

sim(v_hi, v_goodbye)

# EXAMPLE: FOOD

function make_similar!(hvs, v=nothing; f=0.4, randpos=true)
    isnothing(v) && (v = rand((-1, 1), N))  # new vector as source of similarity
    m = rand(N) .< f  # mask
    for hv in hvs
        # exchange bits
        hv[m] .= v[m]
        # optionally pick different locations
        randpos && (m = rand(N) .< f)
    end
end

apple = hv()
pear = hv()
tomato = hv()
milk = hv()
yoghurt = hv()
cheese = hv()
egg = hv()
flour = hv()
bread = hv()
pasta = hv()
sandwich = hv()
omelete = hv()

make_similar!([apple, pear], f=0.5)
make_similar!([apple, pear, tomato], f=0.3)
make_similar!([yoghurt, cheese], milk)
make_similar!([omelete], tomato, f=0.2)
make_similar!([omelete], cheese, f=0.2)
make_similar!([omelete], egg)
make_similar!([bread, pasta], flour, f=0.3)
make_similar!([sandwich], cheese, f=0.2)
make_similar!([sandwich], tomato, f=0.2)
make_similar!([sandwich], bread, f=0.3)

sim(apple, pear)
sim(apple, tomato)
sim(apple, egg)

sim(yoghurt, milk)
sim(omelete, egg)

sim(omelete, cheese)
sim(omelete, tomato)

sim(bread, pasta)
sim(bread, sandwich)
sim(cheese, sandwich)
sim(cheese, bread)

# what is in the omelete?

# show holographic property

sim(bread, sandwich)

f_subselect = 0.1  # select random subselection

subselection = rand(N) .< f_subselect

sum(subselection)

sim(bread[subselection], sandwich[subselection])

# show robustness

function flip(v, f)
    @assert 0 ≤ f ≤ 1 "`f` should be in [0, 1]"
    return [rand() ≤ f ? rand((-1, 1)) : vi for vi in v]
end

f_flip = 0.3

sandwich_flipped = flip(sandwich, f_flip)

sim(sandwich, sandwich_flipped)

sim(bread, sandwich_flipped)




# COMPUTING IN THE HYPERSPACE

# 1. bundling

bundle(hvs) = sign.(sum(hvs))

uv_bundle = bundle((u, v))

sim(uv_bundle, u)

sim(uv_bundle, v)

fruits = bundle((apple, pear, tomato))

sim(fruits, apple)

# todo: this would be a good example for languages!

# 2. binding

bind(u, v) = u .* v

uv_bound = bind(u, v)

sim(uv_bound, u)

sim(uv_bound, v)

u_unbound = bind(uv_bound, v)

u_unbound == u

# 3. shifting

shift(v, k=1) = circshift(v, k)

u_shifted = shift(u)

sim(u_shifted, u)

u_unshifted = shift(u_shifted, -1)

sim(u_unshifted, u)

# some properties

r = hv()

# binding distributes over bundling
sim(bind(r, bundle((u, v))), bundle((bind(r, u), bind(r, v))))

# binding preserves distances
sim(bread, sandwich) ≈ sim(bind(bread, apple), bind(sandwich, apple))


# Text clf

