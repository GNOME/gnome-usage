#ifndef BETTER_BOX_H
#define BETTER_BOX_H

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define BETTER_TYPE_BOX (better_box_get_type())

G_DECLARE_DERIVABLE_TYPE (BetterBox, better_box, BETTER, BOX, GtkBox)

struct _BetterBoxClass
{
	GtkBoxClass parent_class;
};

GtkWidget *better_box_new (void);
gint better_box_get_max_width_request (BetterBox *self);
void better_box_set_max_width_request (BetterBox *self, gint max_width_request);

G_END_DECLS

#endif /* BETTER_BOX_H */