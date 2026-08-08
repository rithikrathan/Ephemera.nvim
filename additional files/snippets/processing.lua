local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	-- ==========================================
	-- STRUCTURE & BOILERPLATE
	-- ==========================================
	s("setup", fmt([[
	void setup() {{
		size({}, {});
		{}
	}}

	void draw() {{
		background({});
		{}
	}}
	]], { i(1, "800"), i(2, "800"), i(3, "// setup"), i(4, "51"), i(0, "// draw") })),

	s("draw", fmt([[
	void draw() {{
		background({});
		{}
	}}
	]], { i(1, "51"), i(0) })),

	s("void", fmt([[
	void {}({}) {{
		{}
	}}
	]], { i(1, "name"), i(2), i(0) })),

	-- ==========================================
	-- INPUT EVENTS
	-- ==========================================
	s("kp", fmt([[
	void keyPressed() {{
		if (key == {}) {{
			{}
		}}
	}}
	]], { i(1, "'s'"), i(0) })),

	s("mp", fmt([[
	void mousePressed() {{
		{}
	}}
	]], { i(0) })),

	s("md", fmt([[
	void mouseDragged() {{
		{}
	}}
	]], { i(0) })),

	-- -- ==========================================
	-- -- SHAPES (PRIMITIVES)
	-- -- ==========================================
	s("rect", fmt("rect({}, {}, {}, {});", { i(1, "x"), i(2, "y"), i(3, "w"), i(4, "h") })),
	s("ellipse", fmt("ellipse({}, {}, {}, {});", { i(1, "x"), i(2, "y"), i(3, "w"), i(4, "h") })),
	s("circle", fmt("circle({}, {}, {});", { i(1, "x"), i(2, "y"), i(3, "r") })),
	s("line", fmt("line({}, {}, {}, {});", { i(1, "x1"), i(2, "y1"), i(3, "x2"), i(4, "y2") })),
	s("point", fmt("point({}, {});", { i(1, "x"), i(2, "y") })),
	s("tri",
		fmt("triangle({}, {}, {}, {}, {}, {});",
			{ i(1, "x1"), i(2, "y1"), i(3, "x2"), i(4, "y2"), i(5, "x3"), i(6, "y3") })),
	s("quad",
		fmt("quad({}, {}, {}, {}, {}, {}, {}, {});",
			{ i(1, "x1"), i(2, "y1"), i(3, "x2"), i(4, "y2"), i(5, "x3"), i(6, "y3"), i(7, "x4"), i(8, "y4") })),
	s("arc",
		fmt("arc({}, {}, {}, {}, {}, {});", { i(1, "x"), i(2, "y"), i(3, "w"), i(4, "h"), i(5, "start"), i(6, "stop") })),
	s("bezier",
		fmt("bezier({}, {}, {}, {}, {}, {}, {}, {});",
			{ i(1, "x1"), i(2, "y1"), i(3, "cx1"), i(4, "cy1"), i(5, "cx2"), i(6, "cy2"), i(7, "x2"), i(8, "y2") })),

	-- ==========================================
	-- ATTRIBUTES & COLOR
	-- ==========================================
	s("bg", fmt("background({});", { i(1, "51") })),
	s("fill", fmt("fill({});", { i(1, "255") })),
	s("nofill", t("noFill();")),
	s("str", fmt("stroke({});", { i(1, "255") })),
	s("nostr", t("noStroke();")),
	s("strw", fmt("strokeWeight({});", { i(1, "2") })),
	s("rectmode", c(1, { t("rectMode(CENTER);"), t("rectMode(CORNER);") })),
	s("colormode", c(1, { t("colorMode(HSB, 360, 100, 100);"), t("colorMode(RGB, 255, 255, 255);") })),

	-- ==========================================
	-- TRANSFORMATION & MATRIX
	-- ==========================================
	s("push", fmt([[
	pushMatrix();
	translate({}, {});
	{}
	popMatrix();
	]], { i(1, "x"), i(2, "y"), i(0) })),

	s("trans", fmt("translate({}, {});", { i(1, "x"), i(2, "y") })),
	s("rot", fmt("rotate({});", { i(1, "angle") })),
	s("scale", fmt("scale({});", { i(1, "val") })),

	-- ==========================================
	-- MATH functions
	-- ==========================================
	s("map", fmt("map({}, {}, {}, {}, {});", { i(1, "value"), i(2, "0"), i(3, "1"), i(4, "0"), i(5, "100") })),
	s("lerp", fmt("lerp({}, {}, {});", { i(1, "start"), i(2, "stop"), i(3, "amt") })),
	s("dist", fmt("dist({}, {}, {}, {});", { i(1, "x1"), i(2, "y1"), i(3, "x2"), i(4, "y2") })),
	s("rand", fmt("random({}, {});", { i(1, "min"), i(2, "max") })),
	s("noise", fmt("noise({});", { i(1, "t") })),
	s("rad", fmt("radians({});", { i(1, "deg") })),
	s("con", fmt("constrain({}, {}, {});", { i(1, "val"), i(2, "min"), i(3, "max") })),

	-- ==========================================
	-- LOGIC
	-- ==========================================
	s("for", fmt([[
	for (int {} = 0; {} < {}; {}++) {{
		{}
	}}
	]], { i(1, "i"), rep(1), i(2, "count"), rep(1), i(0) })),

	s("if", fmt([[
	if ({}) {{
		{}
	}}
	]], { i(1, "condition"), i(0) })),

	s("print", fmt("println({});", { i(1, "msg") })),

	-- ==========================================
	-- QOL & UTILITIES
	-- ==========================================
	s("lazygui", fmt([[
	import com.krab.lazy.LazyGui;

	LazyGui gui;
	float radius;
	boolean export = false;

	void setup() {{
		size(600, 600, P2D);
		gui = new LazyGui(this);
		smooth(8);
		calculate();
	}}

	void draw() {{
		background(10,10,30);
		translate(width/2, height/2);
		scale(1,-1);
		handleGui();

		// Draw the circle based on the slider
		noStroke();
		fill(255);
		circle(0, 0, radius * 2);

		if(export){{
			// save frame logic here
		}}

	}}

	void handleGui() {{
		radius = gui.slider("radius", 100, 10, 400);

		if (gui.button("reset")) {{
			radius = 10;
			gui.sliderSet("radius", 10);
		}}

		if (gui.button("quit")) {{
			exit();
		}}

		if (gui.hasChanged("radius")) {{
			calculate();
		}}
	}}

	void calculate() {{
		{}
	}}
	]], {
		i(1, "// Logic")
	})),


	-- Class Template: Standard Processing Class
	s("class", fmt([[
	class {} {{
		float x, y;

		{}(float x, float y) {{
			this.x = x;
			this.y = y;
		}}

		void update() {{
			{}
		}}

		void display() {{
			{}
		}}
	}}
	]], { i(1, "Name"), rep(1), i(2, "// logic"), i(0, "// draw") })),

	-- Save Frame: Saves on 's' press
	s("save", fmt([[
	if (keyPressed && key == 's') {{
		saveFrame("out-######.png");
		println("Frame saved.");
	}}
	]], {})),

	-- Center: Fast center
	s("center", t("translate(width/2, height/2);")),

	-- Polar: Convert polar to cartesian
	s("polar", fmt([[
	float x = {} + cos({}) * {};
	float y = {} + sin({}) * {};
	]], { i(1, "cx"), i(2, "angle"), i(3, "rad"), rep(1), rep(2), rep(3) })),
}
