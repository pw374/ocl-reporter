(* year, month, date, hour, minute *)
let mk_date y m =
  (y,m,1,12,0), (Printf.sprintf "%.4d-%.2d-%.2d" y m 1)

let monthlies = [
  mk_date 2013 6;
  mk_date 2013 5;
  mk_date 2013 4;
  mk_date 2013 3;
  mk_date 2013 2;
  mk_date 2013 1;
  mk_date 2012 12;
  mk_date 2012 11;
]
