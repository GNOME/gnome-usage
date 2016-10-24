#include <glib/gi18n.h>

#include "better-box.h"

typedef struct
{
	gint max_width_request;
} BetterBoxPrivate;

enum {
	PROP_0,
	PROP_MAX_WIDTH_REQUEST,
	LAST_PROP
};

G_DEFINE_TYPE_WITH_PRIVATE (BetterBox, better_box, GTK_TYPE_BOX)

static GParamSpec *properties [LAST_PROP];

static void
better_box_get_preferred_width (GtkWidget *widget,
                             gint      *min_width,
                             gint      *nat_width)
{
	BetterBox *self = (BetterBox *)widget;
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	g_assert (BETTER_IS_BOX (self));

	GTK_WIDGET_CLASS (better_box_parent_class)->get_preferred_width (widget, min_width, nat_width);

	if (priv->max_width_request > 0)
	{
		if (*min_width > priv->max_width_request)
			*min_width = priv->max_width_request;

		if (*nat_width > priv->max_width_request)
			*nat_width = priv->max_width_request;
	}
}

static void
better_box_get_property (GObject    *object,
                      guint       prop_id,
                      GValue     *value,
                      GParamSpec *pspec)
{
	BetterBox *self = BETTER_BOX (object);
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	switch (prop_id)
	{
		case PROP_MAX_WIDTH_REQUEST:
			g_value_set_int (value, priv->max_width_request);
			break;

		default:
			G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
	}
}

static void
better_box_set_property (GObject      *object,
                      guint         prop_id,
                      const GValue *value,
                      GParamSpec   *pspec)
{
	BetterBox *self = BETTER_BOX (object);
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	switch (prop_id)
	{
		case PROP_MAX_WIDTH_REQUEST:
			priv->max_width_request = g_value_get_int (value);
			gtk_widget_queue_resize (GTK_WIDGET (self));
			break;

		default:
			G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
	}
}

gint
better_box_get_max_width_request (BetterBox *self)
{
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	return priv->max_width_request;
}

void
better_box_set_max_width_request (BetterBox *self, gint max_width_request)
{
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	priv->max_width_request = max_width_request;
	gtk_widget_queue_resize (GTK_WIDGET (self));
}

GtkWidget *
better_box_new (void)
{
	return g_object_new (BETTER_TYPE_BOX, NULL);
}

static void
better_box_class_init (BetterBoxClass *klass)
{
	GObjectClass *object_class = G_OBJECT_CLASS (klass);
	GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

	object_class->get_property = better_box_get_property;
	object_class->set_property = better_box_set_property;

	widget_class->get_preferred_width = better_box_get_preferred_width;

	properties [PROP_MAX_WIDTH_REQUEST] =
			g_param_spec_int ("max-width-request",
			                  "Max Width Request",
			                  "Max Width Request",
			                  -1,
			                  G_MAXINT,
			                  -1,
			                  (G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));

	g_object_class_install_properties (object_class, LAST_PROP, properties);
}

static void
better_box_init (BetterBox *self)
{
	BetterBoxPrivate *priv = better_box_get_instance_private (self);

	priv->max_width_request = -1;
}