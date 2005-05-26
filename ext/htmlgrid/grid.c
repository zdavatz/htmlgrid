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

#include "grid.h"
#include "st.h"

void Init_Grid()
{
	grid = rb_define_class_under(htmlgrid, "Grid", rb_cObject);
	rb_define_singleton_method(grid, "new", grid_new, -1);
	rb_define_method(grid, "initialize", grid_initialize, 1);
	rb_define_method(grid, "height", grid_height, 0);
	rb_define_method(grid, "width", grid_width, 0);
	rb_define_method(grid, "to_html", grid_to_html, 1);
	rb_define_method(grid, "add", grid_add, -1);
	rb_define_method(grid, "add_field", grid_add_field, 3);
	rb_define_method(grid, "add_attribute", grid_add_attribute, -1);
	rb_define_method(grid, "set_row_attributes", 
			grid_row_set_attributes, 2);
	rb_define_method(grid, "add_tag", grid_add_tag, -1);
	rb_define_method(grid, "add_style", grid_add_style, -1);
	rb_define_method(grid, "add_component_style", 
			grid_add_component_style, -1);
	rb_define_method(grid, "push", grid_push, 1);
	rb_define_method(grid, "set_colspan", grid_set_colspan, -1);
	rb_define_method(grid, "set_attribute", grid_set_attribute, 2);
	rb_define_method(grid, "set_attributes", grid_set_attributes, 1);
	rb_define_method(grid, "insert_row", grid_insert_row, 2);
	rb_define_method(grid, "field_attribute", grid_field_attribute, 3);
}

long grid_pos(cg, xpos, ypos)
	cGrid *cg;
	long xpos, ypos;
{
	return ypos * cg->width + xpos;
}

VALUE rb_hsh_store_pair(pair, hsh)
	VALUE pair, hsh;
{
	VALUE key, value;
	key = rb_ary_entry(pair, 0);
	value = rb_ary_entry(pair, 1);
	return rb_hash_aset(hsh, key, value);
}

cField * grid_create_field()
{
	cField * cf;
	cf = ALLOC(cField);
	cf->attributes = Qnil;
	cf->colspan = 1;
	cf->capacity = 1;
	cf->content = ALLOC_N(VALUE, cf->capacity);
	cf->content_count = 0;
	strcpy(cf->tag, "TD");
	return cf;
}

void grid_set_dimensions(cg, width, height)
	cGrid *cg;
	long width, height;
{
	if(cg->width >= width && cg->height >= height) return;

	long stop, fields, idx, xval, yval, mwidth, mheight; 

	/* make space for more rows */
	if(height > cg->height)
	{
		REALLOC_N(cg->row_attributes, VALUE, height);
		for(yval=cg->height; yval < height; yval++)
		{
			cg->row_attributes[yval] = Qnil;	
		}
	}

	mheight = (height > cg->height) ? height : cg->height;
	mwidth = (width > cg->width) ? width : cg->width;

	stop = mwidth * mheight;
	fields = cg->width * cg->height;
	cField *tmp[cg->capacity];
	for(idx=0; idx < fields; idx++)
	{
		tmp[idx] = cg->fields[idx];
	}

	/* sufficient capacity? */
	if(stop > cg->capacity)
	{
		while(stop > cg->capacity)
		{
			cg->capacity *= 2;
		}
		//printf("reallocating %li fields\n", cg->capacity);
		REALLOC_N(cg->fields, cField *, cg->capacity);
	}

	/* has the maximum width changed? */
	if(mwidth > cg->width)
	{
		for(yval=0, idx=0; yval < mheight; yval++)
		{
			for(xval=0; xval < mwidth; xval++)	
			{
				if(yval < cg->height && xval < cg->width)
				{
					cg->fields[idx] = tmp[grid_pos(cg, xval, yval)];
				}
				else
				{
					cg->fields[idx] = grid_create_field();
				}
				idx++;
			}
		}
	}
	/* ..otherwise use the slightly more efficient algo */
	else
	{
		for(idx=0; idx < fields; idx++)
		{
			cg->fields[idx] = tmp[idx];
		}
		//printf("initializing fields %li to %li\n", fields, stop);
		for(idx=fields; idx < stop; idx++)
		{
			//printf("creating new field at idx: %i\n", idx);
			cg->fields[idx] = grid_create_field();
		}
	}

	cg->height = mheight;
	cg->width = mwidth;
}

cGrid *grid_create()
{
	long init_cap = 4;
	cGrid * cg;
	cg = ALLOC(cGrid);
	cg->attributes = rb_hash_new();
	cg->width = 1;
	cg->height = 1;
	cg->capacity = init_cap;
	cg->fields = ALLOC_N(cField *, init_cap);
	cg->fields[0] = grid_create_field();
	cg->row_attributes = ALLOC_N(VALUE, cg->height);
	cg->row_attributes[0] = Qnil;
	return cg;
}

void grid_mark(cg)
	cGrid * cg;
{
	cField * cf;
	long idx, cdx, stop;
	stop = cg->height * cg->width;

	rb_gc_mark(cg->attributes);
	for(idx=0; idx<stop; idx++)
	{
		cf = cg->fields[idx];
		rb_gc_mark(cf->attributes);
		for(cdx=0; cdx < cf->content_count; cdx++)
		{
			rb_gc_mark(cf->content[cdx]);
		}
	}
	for(idx=0; idx < cg->height; idx++)
	{
		rb_gc_mark(cg->row_attributes[idx]);	
	}
}

void grid_free(cg)
	cGrid * cg;
{
	long idx;
	cField * cf;
	for(idx=0; idx < (cg->width * cg->height); idx++)
	{
		cf = cg->fields[idx];
		free(cf->content);
		free(cf);
	}
	free(cg->row_attributes);
	free(cg->fields);
	free(cg);
}

VALUE grid_new(argc, argv, klass)
	long argc;
	VALUE *argv;
	VALUE klass;
{
	VALUE instance, attr, argv2[1];
	cGrid *internal;

	rb_scan_args(argc, argv, "01", &attr);
	argv2[0] = (attr == Qnil) ? rb_hash_new() : attr;

	internal = grid_create();
	instance = Data_Wrap_Struct(klass, grid_mark, grid_free, internal);
	rb_obj_call_init(instance, 1, argv2);

	return instance;
}

VALUE grid_initialize(self, attr)
	VALUE self, attr;
{
	VALUE key;
	cGrid * cg;
	Data_Get_Struct(self, cGrid, cg);

	key = rb_str_new2("cellspacing");
	if(!st_lookup(RHASH(attr)->tbl, key, 0))
	{
		rb_hash_aset(attr, key, rb_str_new2("0"));
	}
	cg->attributes = attr;
	
	return self;
}

VALUE grid_height(self)
	VALUE self;
{
	cGrid * cg;
	Data_Get_Struct(self, cGrid, cg);
	return INT2NUM(cg->height);
}

VALUE grid_width(self)
	VALUE self;
{
	cGrid * cg;
	Data_Get_Struct(self, cGrid, cg);
	return INT2NUM(cg->width);
}

VALUE grid_cat_attribute(pair, string)
	VALUE pair, string;
{
	VALUE val;
	char *key, *value;
	long len;
	val = rb_ary_entry(pair, 1);
	if(val == Qnil)
		return string;
	key = STR2CSTR(rb_ary_entry(pair, 0));
	value = STR2CSTR(rb_funcall(val, rb_intern("to_s"), 0));
	char attr[strlen(key) + strlen(value) + 5];
	len = sprintf(attr, " %s=\"%s\"", key, value);
	return rb_str_cat(string, attr, len);
}

void grid_cat_starttag(string, tagname, attributes)
	VALUE string, attributes;
	char *tagname;
{
	char tagstart[strlen(tagname) + 2];
	long len;
	len = sprintf(tagstart, "<%s", tagname);
	rb_str_cat(string, (char *)tagstart, len);
	rb_iterate(rb_each, attributes, grid_cat_attribute, string);
	rb_str_cat(string, ">", 1);
}

void grid_cat_endtag(string, tagname)
	VALUE string;
	char *tagname;
{
	char tag[strlen(tagname) + 4];
	long len;
	len = sprintf(tag, "</%s>", tagname);
	rb_str_cat(string, tag, len);
}

VALUE rb_hsh_update(hsh1, hsh2)
	VALUE hsh1, hsh2;
{
	return rb_iterate(rb_each, hsh2, rb_hsh_store_pair, hsh1);
}

VALUE grid_store_allowed_attribute(pair, attrs)
	VALUE pair, attrs;
{
	char* key;

	key = STR2CSTR(rb_ary_entry(pair, 0));
	if( strcasecmp(key, "align") == 0 
			|| strcasecmp(key, "class") == 0
			|| strcasecmp(key, "colspan") == 0 
			|| strcasecmp(key, "style") == 0
			|| strcasecmp(key, "tag") == 0
			|| strcasecmp(key, "title") == 0)
	{
		return rb_hsh_store_pair(pair, attrs);
	}
	else 
	{
		return Qnil;
	}
}

const char * tr_open = "<TR>";
const char * tr_close = "</TR>";

VALUE grid_to_html(self, cgi)
	VALUE self, cgi;
{
	cGrid * cg;
	cField * cf;
	VALUE item, result, attrs;
	ID to_html = rb_intern("to_html");
	ID to_s = rb_intern("to_s");
	ID attributes = rb_intern("attributes");
	long idx, cdx, xval, yval, spanplus, len;
	Data_Get_Struct(self, cGrid, cg);
	//attrs = rb_iv_get(self, "@attributes");
	result = rb_str_new2("");
	grid_cat_starttag(result, "TABLE", cg->attributes);
	for(idx=0, yval=0; yval < cg->height; yval++)
	{
		if(cg->row_attributes[yval] == Qnil)
			rb_str_cat(result, tr_open, 4);
		else
			grid_cat_starttag(result, "TR", cg->row_attributes[yval]);

		for(xval=0; xval < cg->width; xval++, idx++)
		{
			//printf("writing out field at idx:%i\n", idx);
			cf = cg->fields[idx];
			if((spanplus = cf->colspan - 1))
			{
				xval += spanplus;
				idx += spanplus;
			}	
			attrs = rb_hash_new();
/*
			for(cdx=0; cdx<cf->content_count; cdx++)
			{
				item = cf->content[cdx];
				if(rb_respond_to(item, attributes))
				{
					rb_warn("Outward Propagation of attributes is deprecated");
					rb_iterate(rb_each, rb_funcall(item, attributes, 0), 
							grid_store_allowed_attribute, attrs);
				}
			}
*/
			if(cf->attributes != Qnil)
				rb_hsh_update(attrs, cf->attributes);
			if(cf->colspan > 1)
			{
				char spanstr[cf->colspan/10];
				len = sprintf(spanstr, "%li", cf->colspan);
				rb_hash_aset(attrs, rb_str_new2("colspan"), 
						rb_str_new(spanstr, len));
			}

			grid_cat_starttag(result, cf->tag, attrs);
			
			if(cf->content_count == 0)
				rb_str_cat(result, "&nbsp;", 6);
			else
			{
				for(cdx=0; cdx<cf->content_count; cdx++)
				{
					item = cf->content[cdx];
					if(rb_obj_class(item) == rb_cString)
						rb_str_concat(result, item);
					else if(rb_respond_to(item, to_html))
					{
						VALUE item_html = rb_funcall(item, to_html, 1, cgi);
						if(rb_obj_is_kind_of(item_html, rb_cString) != Qtrue)
							rb_str_cat(result, "&nbsp;", 6);
						else
							rb_str_concat(result, item_html);
					}
					else if(item == Qnil)
						rb_str_cat(result, "&nbsp;", 6);
					else if(rb_obj_is_kind_of(item, rb_eException) == Qtrue)
					{
						rb_str_cat(result, "<!--\n", 5);
						rb_str_concat(result, 
								rb_funcall(rb_obj_class(item), to_s, 0));
						rb_str_cat(result, "\n", 1);
						rb_str_concat(result, 
								rb_funcall(item, rb_intern("message"), 0));
						rb_str_cat(result, "\n", 1);
						VALUE bt = rb_funcall(item, rb_intern("backtrace"), 0);
						rb_str_concat(result, rb_funcall(bt, rb_intern("join"), 
									1, rb_str_new2("\n")));
						rb_str_cat(result, "-->\n", 4);
					}
					else
						rb_str_concat(result, rb_funcall(item, to_s, 0));
				}
			}
			grid_cat_endtag(result, cf->tag);
		}
		rb_str_cat(result, tr_close, 5);
	}
	rb_str_cat(result, "</TABLE>", 8);
	return result;
}

void grid_field_add_content(cf, content)
	cField * cf;
	VALUE content;
{
	long pos;
	if(cf->capacity <= cf->content_count)
	{
/*
		long idx, oldcap, newcap;
		VALUE tmp[cf->capacity];
		oldcap = cf->capacity;
		for(idx=0; idx<oldcap; idx++)
		{
			tmp[idx] = cf->content[idx];
		}
		newcap = cf->capacity * 2;
*/
		cf->capacity *= 2;
		REALLOC_N(cf->content, VALUE, cf->capacity);//newcap);
	}
	pos = cf->content_count;
	cf->content_count++;
	cf->content[pos] = content;
}

VALUE grid_label2ary(item, ary)
{
	return rb_ary_push(ary, item);
}

VALUE grid_add(argc, argv, self)
	long argc;
	VALUE *argv, self;
{
	VALUE item, xval, yval, colflag;

	rb_scan_args(argc, argv, "31", &item, &xval, &yval, &colflag);
	if(rb_funcall(item, rb_intern("is_a?"), 1, rb_mEnumerable) == Qtrue)
	{
		VALUE tmp;
		if(rb_obj_class(item) == rb_cString)
		{
			return grid_add_field(self, item, xval, yval);
		}
		else if(rb_obj_class(item) == rb_cArray)
		{
			tmp = item;
		}
		else
		{
			tmp = rb_ary_new();
			rb_iterate(rb_each, item, grid_label2ary, tmp);
		}

		if(colflag == Qtrue)
			return grid_add_column(self, tmp, xval, yval);
		else
			return grid_add_row(self, tmp, xval, yval);
	}

	return grid_add_field(self, item, xval, yval);
}

VALUE grid_add_field(self, item, xval, yval)
	VALUE self, item, xval, yval;
{
	cGrid *cg;
	cField *cf;
	long xpos, ypos;
	Data_Get_Struct(self, cGrid, cg);

	xpos = NUM2INT(xval);
	ypos = NUM2INT(yval);
	grid_set_dimensions(cg, xpos + 1, ypos + 1);
	
	cf = cg->fields[grid_pos(cg, xpos, ypos)];
	if(item == Qnil)
	{
		return Qnil;
	}
	else
	{
		grid_field_add_content(cf, item);
		return item;
	}
}

VALUE grid_add_row(self, item, xval, yval)
	VALUE self, item, xval, yval;
{
	cGrid *cg;
	cField *cf;
	long xpos, ypos, pos, len, stop, idx;
	Data_Get_Struct(self, cGrid, cg);

	len = RARRAY(item)->len;
	xpos = NUM2INT(xval);
	ypos = NUM2INT(yval);
	stop = xpos + len;
	grid_set_dimensions(cg, stop, ypos + 1);

	for(pos = xpos, idx = 0; pos < stop; pos++, idx++)
	{
		cf = cg->fields[grid_pos(cg, pos, ypos)];
		grid_field_add_content(cf, rb_ary_entry(item, idx));
	}
	return item;
}

VALUE grid_add_column(self, item, xval, yval)
	VALUE self, item, xval, yval;
{
	cGrid *cg;
	cField *cf;
	long xpos, ypos, pos, len, stop, idx;
	Data_Get_Struct(self, cGrid, cg);

	len = RARRAY(item)->len;
	xpos = NUM2INT(xval);
	ypos = NUM2INT(yval);
	stop = ypos + len;
	grid_set_dimensions(cg, xpos + 1, stop);

	for(pos = ypos, idx=0 ; pos < stop; pos++, idx++)
	{
		cf = cg->fields[grid_pos(cg, xpos, pos)];
		grid_field_add_content(cf, rb_ary_entry(item, idx));
	}
	return item;
}

VALUE grid_push(self, item)
	VALUE self, item;
{
	cGrid *cg;
	cField * cf;
	Data_Get_Struct(self, cGrid, cg);

	long height = cg->height;
	grid_set_dimensions(cg, cg->width, height + 1);
	cf = cg->fields[grid_pos(cg, 0, height)];
	grid_field_add_content(cf, item);
	cf->colspan = cg->width;
	return item;
}

VALUE grid_set_colspan(argc, argv, self)
	long argc; 
	VALUE *argv, self;
{
	VALUE xval, yval, span;

	cGrid *cg;
	cField * cf;
	Data_Get_Struct(self, cGrid, cg);
	long xpos, ypos, spanval;

	rb_scan_args(argc, argv, "21", &xval, &yval, &span);
	xpos = NUM2INT(xval);
	ypos = NUM2INT(yval);
	if(span == Qnil)
		spanval = cg->width - xpos;
	else
		spanval = NUM2INT(span);
	grid_set_dimensions(cg, xpos + spanval, ypos + 1);
	cf = cg->fields[grid_pos(cg, xpos, ypos)];
	cf->colspan = spanval;
	return span;
}

VALUE grid_set_attribute(self, key, value)
	VALUE self, key, value;
{
	cGrid * cg;
	Data_Get_Struct(self, cGrid, cg);
	return rb_hash_aset(cg->attributes, key, value);
}

VALUE grid_set_attribute_pair(pair, cg)
	VALUE pair;
	cGrid *cg;
{
	return rb_hsh_store_pair(pair, cg->attributes);
}

VALUE grid_set_attributes(self, attr)
	VALUE self, attr;
{
	cGrid * cg;
	Data_Get_Struct(self, cGrid, cg);
	rb_iterate(rb_each, attr, grid_set_attribute_pair, (VALUE)cg);
	return attr;
}

VALUE grid_insert_row(self, yval, item)
	VALUE self, yval, item;
{
	cGrid *cg;
	cField *cf;
	long yint, move, idx, tmpx, first, last;
	Data_Get_Struct(self, cGrid, cg);
	VALUE argv[3];

	yint = NUM2INT(yval);
	move = (cg->height - yint) * cg->width;
	grid_set_dimensions(cg, cg->width, cg->height + 1);
	first = (cg->height * cg->width);
	last = first-move;
	for(idx = first-1, tmpx=idx-cg->width; idx >= last; idx--, tmpx--)
	{
		cf = cg->fields[idx];
		cg->fields[idx] = cg->fields[tmpx];
		cg->fields[tmpx] = cf;
	}
	first = cg->width * yint;
	last = yint + cg->width;
	
	argv[0] = item;
	argv[1] = INT2FIX(0);
	argv[2] = yval;
	grid_add(3, argv, self);
	return item;
}

void grid_block_iterate(cg, xint, yint, wint, hint, callback, arg)
	cGrid * cg;
	long xint, yint, wint, hint;
	void * callback ();
	VALUE arg;
{
	cField * cf;
	long yend, ypos, pos, idx; 

	yend = yint + hint;
	grid_set_dimensions(cg, xint + wint, yend);
	for(ypos = yint; ypos < yend; ypos++)
	{
		pos = grid_pos(cg, xint, ypos);
		for(idx=0; idx < wint; idx++, pos++)
		{
			cf = cg->fields[pos];
			callback(cf, arg);
		}
	}
}

VALUE grid_iterate(argc, argv, self, callback, creative)
	long argc;
	VALUE *argv, self;
	void * callback();
	int creative;
{
	VALUE value, xval, yval, wval, hval;
	cGrid *cg;
	long xint, yint, wint, hint;

	rb_scan_args(argc, argv, "32", &value, &xval, &yval, &wval, &hval);
	Data_Get_Struct(self, cGrid, cg);
	xint = NUM2INT(xval);
	yint = NUM2INT(yval);
	if(wval == Qnil)
		wint = 1;
	else
		wint = NUM2INT(wval);
	if(hval == Qnil)
		hint = 1;
	else
		hint = NUM2INT(hval);

	if(!creative)
	{
		if(xint >= cg->width || yint >= cg->height)	
			return Qnil;
		if((xint + wint) > cg->width)
			wint = cg->width - xint;
		if((yint + hint) > cg->height)
			hint = cg->height - yint;
	}

	grid_block_iterate(cg, xint, yint, wint, hint, 
			callback, value);

	return value;	
}

void grid_field_add_tag(cf, tagname)
	cField * cf;
	VALUE tagname;
{
	strcpy(cf->tag, STR2CSTR(tagname));
}

VALUE grid_add_tag(argc, argv, self)
	long argc;
	VALUE *argv, self;
{
	return grid_iterate(argc, argv, self, grid_field_add_tag, 1);
}	

void grid_field_add_attribute(cf, pair)
	cField * cf;
	VALUE pair;
{
	if(cf->attributes == Qnil)
		cf->attributes = rb_hash_new();
	rb_hsh_store_pair(pair, cf->attributes);
}

VALUE grid_row_set_attributes(self, ahash, yval)
	VALUE self, ahash, yval;
{
	cGrid * cg;
	long ypos;
	Data_Get_Struct(self, cGrid, cg);
	ypos = NUM2INT(yval);

	grid_set_dimensions(cg, cg->width, ypos + 1);
	cg->row_attributes[ypos] = ahash;

	return ahash;
}

VALUE grid_add_attribute(argc, argv, self)
	long argc;
	VALUE *argv, self;
{
	long argc2, idx;
	argc2 = argc - 1;
	VALUE key, value, xval, yval, wval, hval, pair;
	VALUE argv2[argc2];
	rb_scan_args(argc, argv, "42", 
			&key, &value, &xval, &yval, &wval, &hval);

	pair = rb_ary_new();
	rb_ary_push(pair, key);
	rb_ary_push(pair, value);

	argv2[0] = pair;
	for(idx=1; idx<argc2; idx++)
	{
		argv2[idx] = argv[idx + 1];
	}
		
	return grid_iterate(argc2, argv2, self, 
			grid_field_add_attribute, 1);
}	

void grid_field_add_component_style(cf, style)
	cField * cf;
	VALUE style;
{
	ID set_attribute = rb_intern("set_attribute");
	VALUE item;
	long idx;
	for(idx=0; idx<cf->content_count; idx++)
	{
		item = cf->content[idx];	
		if(rb_respond_to(item, set_attribute))
		{
			rb_funcall(item, set_attribute, 2,
					rb_str_new2("class"), style);
		}
	}
}

VALUE grid_add_component_style(argc, argv, self)
	long argc;
	VALUE *argv, self;
{
	return grid_iterate(argc, argv, self, 
			grid_field_add_component_style, 0);
}

void grid_field_add_style(cf, style)
	cField * cf;
	VALUE style;
{
	if(cf->attributes == Qnil)
		cf->attributes = rb_hash_new();
	rb_hash_aset(cf->attributes, rb_str_new2("class"), style);
}

VALUE grid_add_style(argc, argv, self)
	long argc;
	VALUE *argv, self;
{
	return grid_iterate(argc, argv, self, grid_field_add_style, 1);
}

VALUE grid_field_attribute(self, name, xval, yval)
	VALUE self, name, xval, yval;
{
	cGrid * cg;
	cField * cf; 
	long xpos, ypos;
	Data_Get_Struct(self, cGrid, cg);
	xpos = NUM2INT(xval);
	ypos = NUM2INT(yval);

	if((xpos >= cg->width) || (ypos >= cg->height)) 
		return Qnil;
	cf = cg->fields[grid_pos(cg, xpos, ypos)];
	return rb_hash_aref(cf->attributes, name);
}
