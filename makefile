
scad:=$(shell which openscad openscad-nightly | head -n1)

v_edge_sizes:=2 4 6
h_edge_sizes:=2 3 4 5 6
grid_sizes:=5x6 4x6 3x6 2x6 5x4 4x4 3x4 2x4 5x2 4x2 3x2 2x2

deps:=$(foreach s,$(grid_sizes),build/insert_a_$(s).stl)
deps+=$(foreach s,$(grid_sizes),build/insert_b_$(s).stl)
deps+=$(foreach s,$(grid_sizes),build/corner_lt_$(s).stl)
deps+=$(foreach s,$(grid_sizes),build/corner_lb_$(s).stl)
deps+=$(foreach s,$(grid_sizes),build/corner_rt_$(s).stl)
deps+=$(foreach s,$(grid_sizes),build/corner_rb_$(s).stl)
deps+=$(foreach s,$(v_edge_sizes),build/edge_vertical_$(s).stl)
deps+=$(foreach s,$(h_edge_sizes),build/edge_horizontal_$(s).stl)
deps+=build/clip.stl

all: $(deps)

build/insert_a_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=true' -D'part_insert_grid=false' -D'part_edge_left=false' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=false' -D'part_clip=false' $<

build/insert_b_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=false' -D'part_insert_grid=true' -D'part_edge_left=false' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=false' -D'part_clip=false' $<

build/corner_lt_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=true' -D'part_edge_top=true' -D'part_edge_right=false' -D'part_edge_bottom=false' -D'part_clip=false' $<

build/corner_lb_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=true' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=true' -D'part_clip=false' $<

build/corner_rt_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=false' -D'part_edge_top=true' -D'part_edge_right=true' -D'part_edge_bottom=false' -D'part_clip=false' $<

build/corner_rb_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$(lastword $(subst x, ,$*))' -D'columns=$(firstword $(subst x, ,$*))' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=false' -D'part_edge_top=false' -D'part_edge_right=true' -D'part_edge_bottom=true' -D'part_clip=false' $<

build/edge_vertical_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=$*' -D'columns=1' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=true' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=false' -D'part_clip=false' $<

build/edge_horizontal_%.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=1' -D'columns=$*' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=false' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=true' -D'part_clip=false' $<

build/clip.stl: main.scad
	@echo $@
	@mkdir -p $(@D)
	@$(scad) -o $@ -d $(basename $@).d -o $(basename $@).png --render -D'rows=1' -D'columns=1' -D'part_insert=false' -D'part_insert_grid=false' -D'part_edge_left=false' -D'part_edge_top=false' -D'part_edge_right=false' -D'part_edge_bottom=false' -D'part_clip=true' $<

include $(wildcard build/*.d)

