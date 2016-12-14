/* egg-heap.c
 *
 * Copyright (C) 2014 Christian Hergert <christian@hergert.me>
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define G_LOG_DOMAIN "egg-heap"

#include <string.h>

#include "egg-heap.h"

/**
 * SECTION:egg-heap
 * @title: Heaps
 * @short_description: efficient priority queues using min/max heaps
 *
 * Heaps are similar to a partially sorted tree but implemented as an
 * array. They allow for efficient O(1) lookup of the highest priority
 * item as it will always be the first item of the array.
 *
 * To create a new heap use egg_heap_new().
 *
 * To add items to the heap, use egg_heap_insert_val() or
 * egg_heap_insert_vals() to insert in bulk.
 *
 * To access an item in the heap, use egg_heap_index().
 *
 * To remove an arbitrary item from the heap, use egg_heap_extract_index().
 *
 * To remove the highest priority item in the heap, use egg_heap_extract().
 *
 * To free a heap, use egg_heap_unref().
 *
 * Here is an example that stores integers in a #EggHeap:
 * |[<!-- language="C" -->
 * static int
 * cmpint (gconstpointer a,
 *         gconstpointer b)
 * {
 *   return *(const gint *)a - *(const gint *)b;
 * }
 *
 * int
 * main (gint   argc,
 *       gchar *argv[])
 * {
 *   EggHeap *heap;
 *   gint i;
 *   gint v;
 *
 *   heap = egg_heap_new (sizeof (gint), cmpint);
 *
 *   for (i = 0; i < 10000; i++)
 *     egg_heap_insert_val (heap, i);
 *   for (i = 0; i < 10000; i++)
 *     egg_heap_extract (heap, &v);
 *
 *   egg_heap_unref (heap);
 * }
 * ]|
 */

#define MIN_HEAP_SIZE 16

/*
 * Based upon Mastering Algorithms in C by Kyle Loudon.
 * Section 10 - Heaps and Priority Queues.
 */

G_DEFINE_BOXED_TYPE (EggHeap, egg_heap, egg_heap_ref, egg_heap_unref)

typedef struct _EggHeapReal EggHeapReal;

struct _EggHeapReal
{
  gchar          *data;
  gsize           len;
  volatile gint   ref_count;
  guint           element_size;
  gsize           allocated_len;
  GCompareFunc    compare;
  gchar           tmp[0];
};

#define heap_parent(npos)   (((npos)-1)/2)
#define heap_left(npos)     (((npos)*2)+1)
#define heap_right(npos)    (((npos)*2)+2)
#define heap_index(h,i)     ((h)->data + (i * (h)->element_size))
#define heap_compare(h,a,b) ((h)->compare(heap_index(h,a), heap_index(h,b)))
#define heap_swap(h,a,b)                                                \
  G_STMT_START {                                                        \
      memcpy ((h)->tmp, heap_index (h, a), (h)->element_size);          \
      memcpy (heap_index (h, a), heap_index (h, b), (h)->element_size); \
      memcpy (heap_index (h, b), (h)->tmp, (h)->element_size);          \
 } G_STMT_END

/**
 * egg_heap_new:
 * @element_size: the size of each element in the heap
 * @compare_func: (scope async): a function to compare to elements
 *
 * Creates a new #EggHeap. A heap is a tree-like structure stored in
 * an array that is not fully sorted, but head is guaranteed to be either
 * the max, or min value based on @compare_func. This is also known as
 * a priority queue.
 *
 * Returns: (transfer full): A newly allocated #EggHeap
 */
EggHeap *
egg_heap_new (guint        element_size,
              GCompareFunc compare_func)
{
    EggHeapReal *real;

    g_return_val_if_fail (element_size, NULL);
    g_return_val_if_fail (compare_func, NULL);

    real = g_malloc_n (1, sizeof (EggHeapReal) + element_size);
    real->data = NULL;
    real->len = 0;
    real->ref_count = 1;
    real->element_size = element_size;
    real->allocated_len = 0;
    real->compare = compare_func;

    return (EggHeap *)real;
}

/**
 * egg_heap_ref:
 * @heap: An #EggHeap
 *
 * Increments the reference count of @heap by one.
 *
 * Returns: (transfer full): @heap
 */
EggHeap *
egg_heap_ref (EggHeap *heap)
{
  EggHeapReal *real = (EggHeapReal *)heap;

  g_return_val_if_fail (heap, NULL);
  g_return_val_if_fail (real->ref_count, NULL);

  g_atomic_int_inc (&real->ref_count);

  return heap;
}

static void
egg_heap_real_free (EggHeapReal *real)
{
  g_assert (real);
  g_assert_cmpint (real->ref_count, ==, 0);

  g_free (real->data);
  g_free (real);
}

/**
 * egg_heap_unref:
 * @heap: (transfer full): An #EggHeap
 *
 * Decrements the reference count of @heap by one, freeing the structure
 * when the reference count reaches zero.
 */
void
egg_heap_unref (EggHeap *heap)
{
  EggHeapReal *real = (EggHeapReal *)heap;

  g_return_if_fail (heap);
  g_return_if_fail (real->ref_count);

  if (g_atomic_int_dec_and_test (&real->ref_count))
    egg_heap_real_free (real);
}

static void
egg_heap_real_grow (EggHeapReal *real)
{
  g_assert (real);
  g_assert_cmpint (real->allocated_len, <, G_MAXSIZE / 2);

  real->allocated_len = MAX (MIN_HEAP_SIZE, (real->allocated_len * 2));
  real->data = g_realloc_n (real->data,
                            real->allocated_len,
                            real->element_size);
}

static void
egg_heap_real_shrink (EggHeapReal *real)
{
  g_assert (real);
  g_assert ((real->allocated_len / 2) >= real->len);

  real->allocated_len = MAX (MIN_HEAP_SIZE, real->allocated_len / 2);
  real->data = g_realloc_n (real->data,
                            real->allocated_len,
                            real->element_size);
}

static void
egg_heap_real_insert_val (EggHeapReal   *real,
                          gconstpointer  data)
{
  gint ipos;
  gint ppos;

  g_assert (real);
  g_assert (data);

  if (G_UNLIKELY (real->len == real->allocated_len))
    egg_heap_real_grow (real);

  memcpy (real->data + (real->element_size * real->len),
          data,
          real->element_size);

  ipos = real->len;
  ppos = heap_parent (ipos);

  while ((ipos > 0) && (heap_compare (real, ppos, ipos) < 0))
    {
      heap_swap (real, ppos, ipos);
      ipos = ppos;
      ppos = heap_parent (ipos);
    }

  real->len++;
}

void
egg_heap_insert_vals (EggHeap       *heap,
                      gconstpointer  data,
                      guint          len)
{
  EggHeapReal *real = (EggHeapReal *)heap;
  const gchar *ptr = data;
  guint i;

  g_return_if_fail (heap);
  g_return_if_fail (data);
  g_return_if_fail (len);

  for (i = 0; i < len; i++, ptr += real->element_size)
    egg_heap_real_insert_val (real, ptr);
}

gboolean
egg_heap_extract (EggHeap  *heap,
                  gpointer  result)
{
  EggHeapReal *real = (EggHeapReal *)heap;
  gint ipos;
  gint lpos;
  gint rpos;
  gint mpos;

  g_return_val_if_fail (heap, FALSE);

  if (real->len == 0)
    return FALSE;

  if (result)
    memcpy (result, heap_index (real, 0), real->element_size);

  if (--real->len > 0)
    {
      memmove (real->data,
               heap_index (real, real->len),
               real->element_size);

      ipos = 0;

      while (TRUE)
        {
          lpos = heap_left (ipos);
          rpos = heap_right (ipos);

          if ((lpos < real->len) && (heap_compare (real, lpos, ipos) > 0))
            mpos = lpos;
          else
            mpos = ipos;

          if ((rpos < real->len) && (heap_compare (real, rpos, mpos) > 0))
            mpos = rpos;

          if (mpos == ipos)
            break;

          heap_swap (real, mpos, ipos);

          ipos = mpos;
        }
    }

  if ((real->len > MIN_HEAP_SIZE) && (real->allocated_len / 2) >= real->len)
    egg_heap_real_shrink (real);

  return TRUE;
}

gboolean
egg_heap_extract_index (EggHeap  *heap,
                        guint     index_,
                        gpointer  result)
{
  EggHeapReal *real = (EggHeapReal *)heap;
  gint ipos;
  gint lpos;
  gint mpos;
  gint ppos;
  gint rpos;

  g_return_val_if_fail (heap, FALSE);

  if (real->len == 0)
    return FALSE;

  if (result)
    memcpy (result, heap_index (real, index_), real->element_size);

  real->len--;

  if (real->len && index_ != real->len)
    {
      memcpy (heap_index (real, index_),
              heap_index (real, real->len),
              real->element_size);

      ipos = index_;
      ppos = heap_parent (ipos);

      while (heap_compare (real, ipos, ppos) > 0)
        {
          heap_swap (real, ipos, ppos);
          ipos = ppos;
          ppos = heap_parent (ppos);
        }

      if (ipos == index_)
        {
          while (TRUE)
            {
              lpos = heap_left (ipos);
              rpos = heap_right (ipos);

              if ((lpos < real->len) && (heap_compare (real, lpos, ipos) > 0))
                mpos = lpos;
              else
                mpos = ipos;

              if ((rpos < real->len) && (heap_compare (real, rpos, mpos) > 0))
                mpos = rpos;

              if (mpos == ipos)
                break;

              heap_swap (real, mpos, ipos);

              ipos = mpos;
            }
        }
    }

  if ((real->len > MIN_HEAP_SIZE) && (real->allocated_len / 2) >= real->len)
    egg_heap_real_shrink (real);

  return TRUE;
}
