include("hdc_tutorial.jl")

using Colors

randcol() = RGB(rand(), rand(), rand());
col2vec(col) = [col.r, col.g, col.b]

begin
    # collect all colors
    reds = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("red", n)]
    blues = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("blue", n)]
    greens = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("green", n)]
    oranges = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("orange", n)]
    greys = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("grey", n)]
    yellows = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("yellow", n)]
    whites = [RGB((c ./ 255)...) for (n, c) in Colors.color_names if occursin("white", n)]
end;

emojis_colors = Dict(:🚒 => reds, :💦 => blues, :🌱 => greens, :🌅 => oranges, :🐺 => greys, :🍌 => yellows, :🥚 => whites)

emojis = collect(keys(emojis_colors))

toy_data1 = [rand(emojis) |> l -> (l, rand(emojis_colors[l])) for i in 1:100]

toy_data2 = [rand(emojis) |> l -> (l, shuffle!([rand(emojis_colors[l]), randcol(), randcol()])) for i in 1:500]

emojis_hvs = Dict(s => hv() for s in emojis)

S = randn(N, 3) ./ √3

acolor = randcol()

rgb_col = col2vec(col)

v_col = sign.(S * rgb_col)

col2hv(col) = sign.(S * col2vec(col))

teal = RGB(23 / 256, 146 / 256, 153 / 256)
orange = RGB(254 / 256, 100 / 256, 11 / 256)
sky = RGB(4 / 256, 165 / 256, 229 / 256)

v_teal = col2hv(teal)
v_orange = col2hv(orange)
v_sky = col2hv(sky)

sim(v_teal, v_sky)
sim(v_teal, v_orange)
sim(v_sky, v_orange)

ref_colors = [randcol() for i in 1:1000]
ref_colors_hvs = col2hv.(ref_colors)

hv2col(v) = ref_colors[findmax(sim(v), ref_colors_hvs)[2]]

hv2col(v_col)

toy_data1

emoji_col_hv = [bind(emojis_hvs[emoji], col2hv(col)) for (emoji, col) in toy_data1] |> bundle

av_col_🚒 = bind(emoji_col_hv, emojis_hvs[:🚒]) |> hv2col

average_colors = Dict(emoji => hv2col(bind(emoji_col_hv, emojis_hvs[emoji])) for emoji in emojis)


toy_data2

emoji_col_hv2 = [bind(emojis_hvs[emoji], bundle(col2hv.(colors))) for (emoji, colors) in toy_data2] |> bundle

average_colors2 = Dict(emoji => hv2col(bind(emoji_col_hv2, emojis_hvs[emoji])) for emoji in emojis)