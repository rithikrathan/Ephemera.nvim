local ls = require("luasnip")
local f = ls.function_node
local s = ls.snippet
local t = ls.text_node
local postfix = require("luasnip.extras.postfix").postfix

-- ======================
-- GREEK LETTERS
-- ======================
ls.add_snippets("all", {
	-- lowercase
	s("alpha", t("α")), s("beta", t("β")), s("gamma", t("γ")),
	s("delta", t("δ")), s("epsilon", t("ε")), s("zeta", t("ζ")),
	s("eta", t("η")), s("theta", t("θ")), s("iota", t("ι")),
	s("kappa", t("κ")), s("lambda", t("λ")), s("mu", t("μ")),
	s("nu", t("ν")), s("xi", t("ξ")), s("pi", t("π")),
	s("rho", t("ρ")), s("sigma", t("σ")), s("tau", t("τ")),
	s("upsilon", t("υ")), s("phi", t("φ")), s("chi", t("χ")),
	s("psi", t("ψ")), s("omega", t("ω")),

	-- uppercase
	s("Alpha", t("Α")), s("Beta", t("Β")), s("Gamma", t("Γ")),
	s("Delta", t("Δ")), s("Theta", t("Θ")), s("Lambda", t("Λ")),
	s("Xi", t("Ξ")), s("Pi", t("Π")), s("Sigma", t("Σ")),
	s("Phi", t("Φ")), s("Psi", t("Ψ")), s("Omega", t("Ω")),
})

-- ======================
-- MATH OPERATORS
-- ======================
ls.add_snippets("all", {
	s("+-", t("±")), s("-+", t("∓")),
	s("mul", t("×")), s("div", t("÷")),
	s("nequal", t("≠")), s("le", t("≤")), s("ge", t("≥")),
	s("approx", t("≈")), s("prop", t("∝")),
	s("infinity", t("∞")), s("deg", t("°")),
	s("partial", t("∂")), s("nabla", t("∇")),
	s("integral", t("∫")), s("iintegral", t("∬")), s("iiintegral", t("∭")),
	s("summation", t("∑")), s("prod", t("∏")),
	s("sqrt", t("√")),
})

-- ======================
-- LOGIC & SET THEORY
-- ======================
ls.add_snippets("all", {
	s("forall", t("∀")), s("exists", t("∃")),
	s("in", t("∈")), s("notin", t("∉")),
	s("subset", t("⊂")), s("supset", t("⊃")),
	s("subseteq", t("⊆")), s("supseteq", t("⊇")),
	s("and", t("∧")), s("or", t("∨")),
	s("not", t("¬")), s("xor", t("⊕")),
	s("empty", t("∅")),
})

-- ======================
-- VECTORS & ARROWS
-- ======================
ls.add_snippets("all", {
	s("to", t("→")), s("from", t("←")),
	s("leftright", t("↔")),
	s("uparrow", t("↑")), s("downarrow", t("↓")),
})

ls.add_snippets("all", {
	postfix(".vec", {
		f(function(_, parent)
			return parent.snippet.env.POSTFIX_MATCH .. "⃗"
		end),
	}),
})


-- ======================
-- PHYSICS / CHEMISTRY
-- ======================
ls.add_snippets("all", {
	s("ohm", t("Ω")),
	s("angstrom", t("Å")),
	s("degree", t("°")),
	s("micro", t("µ")),
	s("pm", t("±")),
	s("dot", t("·")),
	s("cdot", t("⋅")),
})

-- ======================
-- MISC SCIENCE
-- ======================
ls.add_snippets("all", {
	s("therefore", t("∴")),
	s("because", t("∵")),
	s("ellipsis", t("…")),
})

-- ======================
-- SUPERSCRIPTS
-- ======================
ls.add_snippets("all", {
	-- numbers
	s("^0", t("⁰")), s("^1", t("¹")), s("^2", t("²")),
	s("^3", t("³")), s("^4", t("⁴")), s("^5", t("⁵")),
	s("^6", t("⁶")), s("^7", t("⁷")), s("^8", t("⁸")),
	s("^9", t("⁹")),

	-- operators
	s("^+", t("⁺")), s("^-", t("⁻")),
	s("^=", t("⁼")), s("^(", t("⁽")), s("^)", t("⁾")),
	s("^pm", t("⁺⁻")),
	s("^inf", t("∞")),

	-- letters (only ones that exist)
	s("^n", t("ⁿ")), s("^i", t("ⁱ")),
})

-- ======================
-- SUBSCRIPTS
-- ======================
ls.add_snippets("all", {
	-- numbers
	s("_0", t("₀")), s("_1", t("₁")), s("_2", t("₂")),
	s("_3", t("₃")), s("_4", t("₄")), s("_5", t("₅")),
	s("_6", t("₆")), s("_7", t("₇")), s("_8", t("₈")),
	s("_9", t("₉")),

	-- operators
	s("_+", t("₊")), s("_-", t("₋")),
	s("_=", t("₌")), s("_(", t("₍")), s("_)", t("₎")),
	s("_pm", t("₊₋")),
	s("_inf", t("∞")),

	-- letters (only ones that exist)
	s("_a", t("ₐ")), s("_e", t("ₑ")), s("_h", t("ₕ")),
	s("_i", t("ᵢ")), s("_j", t("ⱼ")), s("_k", t("ₖ")),
	s("_l", t("ₗ")), s("_m", t("ₘ")), s("_n", t("ₙ")),
	s("_o", t("ₒ")), s("_p", t("ₚ")), s("_r", t("ᵣ")),
	s("_s", t("ₛ")), s("_t", t("ₜ")), s("_u", t("ᵤ")),
	s("_v", t("ᵥ")), s("_x", t("ₓ")),
})
