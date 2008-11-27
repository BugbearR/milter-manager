/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 *  Copyright (C) 2008  Kouhei Sutou <kou@cozmixng.org>
 *
 *  This library is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <string.h>

#include <milter/core.h>

#include "milter-manager-test-utils.h"

static gchar *base_dir = NULL;
const gchar *
milter_manager_test_get_base_dir (void)
{
    const gchar *dir;

    if (base_dir)
        return base_dir;

    dir = g_getenv("BASE_DIR");
    if (!dir)
        dir = ".";

    if (g_path_is_absolute(dir)) {
        base_dir = g_strdup(dir);
    } else {
        gchar *current_dir;

        current_dir = g_get_current_dir();
        base_dir = g_build_filename(current_dir, dir, NULL);
        g_free(current_dir);
    }

    return base_dir;
}

static gboolean
cb_check_emitted (gpointer data)
{
    gboolean *emitted = data;

    *emitted = TRUE;
    return FALSE;
}

void
milter_manager_test_wait_signal (gboolean should_timeout)
{
    gboolean timeout_emitted = FALSE;
    gboolean idle_emitted = FALSE;
    guint timeout_id, idle_id;

    idle_id = g_idle_add_full(G_PRIORITY_DEFAULT,
                              cb_check_emitted, &idle_emitted, NULL);

    timeout_id = g_timeout_add_seconds(1, cb_check_emitted, &timeout_emitted);
    while (!timeout_emitted && !idle_emitted) {
        g_main_context_iteration(NULL, TRUE);
    }

    g_source_remove(idle_id);
    g_source_remove(timeout_id);

    if (should_timeout)
        cut_assert_true(timeout_emitted, "should timeout");
    else
        cut_assert_false(timeout_emitted, "timeout");
}

void
milter_manager_test_pair_inspect (GString *string,
                                  gconstpointer data,
                                  gpointer user_data)
{
    const MilterManagerTestPair *pair = data;

    g_string_append_printf(string, "<<%s>=<%s>>", pair->name, pair->value);
}

static gboolean
string_equal (const gchar *string1, const gchar *string2)
{
    if (string1 == string2)
        return TRUE;

    if (string1 == NULL || string2 == NULL)
        return FALSE;

    return g_strcmp0(string1, string2) == 0;
}

gboolean
milter_manager_test_pair_equal (gconstpointer data1, gconstpointer data2)
{
    const MilterManagerTestPair *pair1 = data1;
    const MilterManagerTestPair *pair2 = data2;

    return string_equal(pair1->name, pair2->name) &&
        string_equal(pair1->value, pair2->value);
}

gint
milter_manager_test_pair_compare (gconstpointer data1, gconstpointer data2)
{
    const MilterManagerTestPair *pair1 = data1;
    const
        MilterManagerTestPair *pair2 = data2;
    gint compare;

    compare = g_strcmp0(pair1->name, pair2->name);
    if (compare == 0)
        return g_strcmp0(pair1->value, pair2->value);
    else
        return compare;
}

MilterManagerTestPair *
milter_manager_test_pair_new (const gchar *name, const gchar *value)
{
    MilterManagerTestPair *pair;

    pair = g_new0(MilterManagerTestPair, 1);
    pair->name = g_strdup(name);
    pair->value = g_strdup(value);

    return pair;
}

void
milter_manager_test_pair_free (MilterManagerTestPair *pair)
{
    g_free(pair->name);
    g_free(pair->value);

    g_free(pair);
}

static void
macro_context_inspect (GString *string,
                       gconstpointer macro_context,
                       gpointer user_data)
{
    gchar *inspected_macro_context;

    inspected_macro_context = gcut_enum_inspect(MILTER_TYPE_COMMAND,
                                                GPOINTER_TO_INT(macro_context));
    g_string_append_printf(string, "<%s>", inspected_macro_context);
    g_free(inspected_macro_context);
}

void
milter_manager_test_defined_macros_inspect (GString *string,
                                            gconstpointer defined_macros,
                                            gpointer user_data)
{
    GHashTable *_defined_macros = (GHashTable *)defined_macros;
    gchar *inspected_defined_macros;

    inspected_defined_macros =
        gcut_hash_table_inspect(_defined_macros,
                                macro_context_inspect,
                                (GCutInspectFunc)gcut_hash_table_string_string_inspect,
                                NULL);
    g_string_append(string, inspected_defined_macros);
    g_free(inspected_defined_macros);
}

gboolean
milter_manager_test_defined_macros_equal (gconstpointer defined_macros1,
                                          gconstpointer defined_macros2)
{
    GHashTable *_defined_macros1 = (GHashTable *)defined_macros1;
    GHashTable *_defined_macros2 = (GHashTable *)defined_macros2;

    return gcut_hash_table_equal(_defined_macros1,
                                 _defined_macros2,
                                 (GEqualFunc)gcut_hash_table_string_equal);
}


/*
vi:ts=4:nowrap:ai:expandtab:sw=4
*/
