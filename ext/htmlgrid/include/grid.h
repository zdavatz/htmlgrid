/* 
 * HtmlGrid -- HyperTextMarkupLanguage Framework
 * Copyright (C) 2003 ywesee - intellectual capital connected
 * Andreas Schrafl, Benjamin Fay, Hannes Wyss, Markus Huggler
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
 * htmlgrid@ywesee.com, www.ywesee.com
 */

#ifndef GRID_H
#define GRID_H

#include "htmlgrid.h"

#ifndef RUBY_19
# define RHASH_TBL(arg) RHASH(arg)->tbl
#endif

VALUE grid;

void Init_Grid();
VALUE grid_new(long argc, VALUE *argv, VALUE klass);
VALUE grid_initialize(VALUE self, VALUE attr);
VALUE grid_height(VALUE self);
VALUE grid_width(VALUE self);
VALUE grid_to_html(VALUE self, VALUE cgi);
VALUE grid_add(long argc, VALUE * argv, VALUE self);
VALUE grid_add_attribute(long argc, VALUE *argv, VALUE self);
VALUE grid_add_row(VALUE self, VALUE item, VALUE xval, VALUE yval);
VALUE grid_add_field(VALUE self, VALUE item, VALUE xval, VALUE yval);
VALUE grid_add_column(VALUE self, VALUE item, VALUE xval, VALUE yval);
VALUE grid_add_tag(long argc, VALUE *argv, VALUE self);
VALUE grid_add_style(long argc, VALUE *argv, VALUE self);
VALUE grid_add_component_style(long argc, VALUE *argv, VALUE self);
VALUE grid_push(VALUE self, VALUE item);
VALUE grid_row_set_attributes(long argc, VALUE *argv, VALUE self);
VALUE grid_set_colspan(long argc, VALUE *argv, VALUE self);
VALUE grid_set_attribute(VALUE self, VALUE key, VALUE value);
VALUE grid_set_attributes(VALUE self, VALUE hash);
VALUE grid_insert_row(VALUE self, VALUE yval, VALUE item);
VALUE grid_field_attribute(VALUE self, VALUE name, VALUE xval, VALUE yval);

typedef struct cGrid cGrid;
typedef struct cField cField;

struct cField {
	VALUE *content;
	long capacity;
	long content_count;
	VALUE attributes;
	char tag[16];
	long colspan;
};

struct cGrid {
	long height;
	long width;
	long capacity;
  long row_capacity;
	VALUE attributes;
	VALUE *row_attributes;
	cField **fields;
};

#endif // HTMLGRID_H
