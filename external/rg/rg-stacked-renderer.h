#ifndef RG_STACKED_RENDERER_H
#define RG_STACKED_RENDERER_H

#include <gdk/gdk.h>

#include "rg-renderer.h"

G_BEGIN_DECLS

#define RG_TYPE_STACKED_RENDERER (rg_stacked_renderer_get_type())

G_DECLARE_FINAL_TYPE (RgStackedRenderer, rg_stacked_renderer, RG, STACKED_RENDERER, GObject)

RgStackedRenderer *rg_stacked_renderer_new (void);
void            rg_stacked_renderer_set_stroke_color      (RgStackedRenderer *self,
                                                        const gchar    *stroke_color);
void            rg_stacked_renderer_set_stroke_color_rgba (RgStackedRenderer *self,
                                                        const GdkRGBA  *stroke_color_rgba);
const GdkRGBA  *rg_stacked_renderer_get_stroke_color_rgba (RgStackedRenderer *self);

G_END_DECLS

#endif /* RG_STACKED_RENDERER_H */
