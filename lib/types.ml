open Core.Std

module Person = struct
  type affiliation = [
    | `Citrix
    | `OnApp
    | `CL
    | `OCP
    | `JSC
    | `Horizon
    | `Google
    | `NYU
    | `UMONS
    | `SRI
  ]

  let to_string (x:affiliation) =
    match x with
    | `Citrix -> "Citrix"
    | `Google -> "Google"
    | `OnApp -> "OnApp"
    | `CL -> "Cambridge Computer Laboratory"
    | `JSC -> "Jane Street Capital"
    | `OCP -> "OCamlPro"
    | `Horizon -> "Horizon"
    | `NYU -> "New York University"
    | `UMONS -> "Universite de Mons, Belgium"
    | `SRI -> "SRI International"

  let cmp (a:affiliation) (b:affiliation) =
    let order = function
    |`CL -> 0
    |`Citrix -> 1
    |`OCP -> 2
    |`JSC -> 3
    |`Horizon -> 4
    |`SRI -> 5
    |`OnApp -> 6
    |`NYU -> 7
    |`UMONS -> 8
    |`Google -> 9
    in compare (order a) (order b)

  type t = {
    id: string;
    name: string;
    affiliation: affiliation;
    role: string;
    homepage: string option;
    bio: string option;
    mugshot: string option;
  }

  (* Group people by affiliation *)
  let by_affiliation =
    List.fold_left ~init:[] ~f:(fun a b ->
      match List.Assoc.find a b.affiliation with
      |None -> List.Assoc.add a b.affiliation [b]
      |Some v ->
        (* TODO is there a List.Assoc.replace? *)
        let l = List.Assoc.remove a b.affiliation in
        List.Assoc.add l b.affiliation (b::v)
    )
end

module Reference = struct

  type link = [
   | `Pdf of string
   | `Blog of string
   | `Github of string * string (* user, repo *)
   | `Github_issues of string * string (* user, repo *)
   | `Github_tag of string * string * string (* user, repo, tag *)
   | `Webpage of string
   | `Video of string
   | `Slideshare of string
   | `Mantis of int
   | `Paper of string * string * string * string * string (* URL, title, authors , conference, conf url *)
  ]
  and t = {
    name: string;
    link: link;
  }

  let github ?(name="Github") owner repo =
    { name; link=(`Github (owner,repo)) }

  let github_issues ?(name="Issues") owner repo =
    { name; link=(`Github_issues (owner,repo)) }

  let webpage ?(name="Homepage") url =
    { name; link=(`Webpage url) }

  let pdf ?(name="PDF") url =
    { name; link=(`Pdf url) }

  let paper ?(name="Paper") ~title ~authors ~conf ~conf_url url = 
    { name=name; link=(`Paper (url, title, authors, conf, conf_url)) }
end

module Output = struct

  type ty = [
   | `Paper of Reference.t (* conference ref *)
   | `Blog_post
   | `Talk of Reference.t (* conference ref *)
   | `Event of string list (* people id list *)
   | `Article of Reference.t (* publication ref *)
   | `Asset
   | `Code
  ]
  and t = {
    id: string;
    ref: Reference.t;
    ty: ty;
    descr: string;
  }
end

module Project = struct

  type status =
    [ `Planning
    | `Doing
    | `Complete
    ]
   
  let status_to_string = function
    |`Planning -> "planning"
    |`Doing -> "doing"
    |`Complete -> "complete"

   type project = {
    project_id: string;
    project_name: string;
    project_owner: Person.t;
    team: Person.t list;
    tasks: task list;
  }
  and task = {
    task_name: string;
    task_descr: string option;
    start: Date.t;
    finish: Date.t option; (* A task with no end date ends up in the "infinity planning column" *)
    owner: Person.t;
    status: status;
    refs: Reference.t list;
  }

  let mk_task ~name ~start ?finish ~owner ?(team=[]) ~status ?(refs=[]) ?descr () =
    let start = Date.of_string start in
    let finish = Option.map finish ~f:Date.of_string in
    { task_name=name; task_descr=descr; start; finish; owner; status; refs }

  let people_in_project p = 
    p.project_owner :: p.team

  let tasks_for_person proj person =
    List.filter proj.tasks (fun t -> t.owner = person)
end
