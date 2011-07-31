["root",
 [{"parent",[{"c1","child one"},{"c2","child two"}]},
  [{"t4","content4"}|
   {"list",[{"t0","el1"},{"t0","el2"},{"t0","el3"}]}],
  [[{"t3","content3"},{"t2","content2"},{"t1","content1"}]]]]

Quote = [[{"t4","content4"}|{"list",[{"t0","el1"},{"t0","el2"},{"t0","el3"}]}],
         [[{"t3","content3"},{"t2","content2"},{"t1","content1"}]]]

["root",
 [{"parent",[{"c1","child one"},{"c2","child two"}]},
  [{"t4","content4"}|
   {"list",[{"t0","el1"},{"t0","el2"},{"t0","el3"}]}],
  [{"t3","content3"},{"t2","content2"},{"t1","content1"}]]]

Res = {[{"parent",[{"c1","child one"},{"c2","child two"}]},
        [{"t4","content4"}|{"list",[{"t0","el1"},{"t0","el2"},{"t0","el3"}]}],
        [{"t3","content3"},{"t2","content2"},{"t1","content1"}]],
       []}
