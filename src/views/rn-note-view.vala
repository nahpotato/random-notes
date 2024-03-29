/*
 * Copyright 2021 Nahuel Gomez https://nahuelwexd.com
 *
 * SPDX-License-Identifier: MIT
 */

[GtkTemplate (ui = "/com/nahuelwexd/RandomNotes/ui/rn-note-view.ui")]
sealed class Rn.NoteView : View {
  Note? _note;

  Binding? title_binding;
  Binding? content_binding;

  [GtkChild]
  unowned Gtk.Button delete_button;

  [GtkChild]
  unowned Gtk.Stack stack;

  [GtkChild]
  unowned Adw.StatusPage empty_view;

  [GtkChild]
  unowned Gtk.ScrolledWindow note_view;

  [GtkChild]
  unowned Gtk.TextBuffer note_title;

  [GtkChild]
  unowned Gtk.TextBuffer note_content;

  public Note? note {
    get { return _note; }
    set {
      if (value == _note)
        return;

      title_binding?.unbind ();
      content_binding?.unbind ();

      if (_note != null)
        _note.notify.disconnect (on_text_updated);

      _note = value;

      stack.visible_child = _note != null ? (Gtk.Widget) note_view : empty_view;
      delete_button.visible = _note != null;

      title_binding = _note?.bind_property (
          "title", note_title, "text", SYNC_CREATE|BIDIRECTIONAL);
      content_binding = _note?.bind_property (
          "content", note_content, "text", SYNC_CREATE|BIDIRECTIONAL);

      if (_note != null)
        _note.notify.connect (on_text_updated);
    }
  }

  static construct {
    set_css_name ("noteview");
  }

  public signal void note_update_requested (Note note);
  public signal void note_removal_requested (Note note);

  [GtkCallback]
  void on_delete_button_clicked () {
    note_removal_requested (note);
  }

  void on_text_updated () {
    note_update_requested (note);
  }
}
