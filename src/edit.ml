open Code_mirror
open Brr

let basic_setup = Jv.get Jv.global "__CM__basic_setup" |> Extension.of_jv

let get_el_by_id i =
  Brr.Document.find_el_by_id G.document (Jstr.of_string i) |> Option.get

let position_div = get_el_by_id "position"

let position_extension =
  let update_position (e : Editor.View.t) =
    let state = Editor.View.state e in
    let doc = Editor.State.doc state in
    let range = Editor.State.selection state |> Editor.Selection.main in
    let position = Editor.Selection.Range.head range in
    let line = Text.line_at doc position in
    let col = position - Text.Line.from line in
    El.set_children position_div
      [
        El.txt' (string_of_int (Text.Line.number line));
        El.txt' ":";
        El.txt' (string_of_int col);
      ]
  in
  Editor.View.Plugin.v update_position |> Editor.View.Plugin.to_extension

let get_doc view =
  let text = Editor.State.doc @@ Editor.View.state view in
  Text.to_jstr_array text |> Array.map Jstr.to_string |> Array.to_list
  |> String.concat "\n"

let editor_key = Jstr.v "try-oxcaml-code"

let local_storage_extension =
  let local = Brr_io.Storage.local Brr.G.window in
  let update_storage (e : Editor.View.t) =
    let state = Editor.View.state e in
    let doc = Editor.State.doc state in
    let s =
      Text.to_jstr_array doc |> Array.to_list |> Jstr.concat ~sep:(Jstr.v "\n")
    in
    Brr_io.Storage.set_item local editor_key s
    |> Brr.Console.log_if_error ~use:()
  in
  Editor.View.Plugin.v update_storage |> Editor.View.Plugin.to_extension

let init ?doc ?(exts = [||]) () =
  let open Editor in
  let config =
    State.Config.create ?doc
      ~extensions:
        (Array.concat
           [
             [| basic_setup; position_extension; local_storage_extension |];
             exts;
           ])
      ()
  in
  let state = State.create ~config () in
  let opts = View.opts ~state ~parent:(get_el_by_id "editor1") () in
  let view : View.t = View.create ~opts () in
  (state, view)

let set view ~doc ~exts =
  let open Editor in
  let config =
    State.Config.create ~doc
      ~extensions:
        (Array.concat
           [
             [| basic_setup; position_extension; local_storage_extension |];
             exts;
           ])
      ()
  in
  let state = State.create ~config () in
  View.set_state view state
