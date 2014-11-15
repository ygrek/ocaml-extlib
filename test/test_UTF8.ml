let substring_inputs =
[
  [|
    "";
    "⟿";
    "⟿ቄ";
    "⟿ቄş";
    "⟿ቄş龟";
    "⟿ቄş龟¯";
  |];
  [|
    "";
    "ç";
    "çe";
    "çek";
    "çeko";
    "çekos";
    "çekosl";
    "çekoslo";
    "çekoslov";
    "çekoslova";
    "çekoslovak";
    "çekoslovaky";
    "çekoslovakya";
    "çekoslovakyal";
    "çekoslovakyala";
    "çekoslovakyalaş";
    "çekoslovakyalaşt";
    "çekoslovakyalaştı";
    "çekoslovakyalaştır";
    "çekoslovakyalaştıra";
    "çekoslovakyalaştıram";
    "çekoslovakyalaştırama";
    "çekoslovakyalaştıramad";
    "çekoslovakyalaştıramadı";
    "çekoslovakyalaştıramadık";
    "çekoslovakyalaştıramadıkl";
    "çekoslovakyalaştıramadıkla";
    "çekoslovakyalaştıramadıklar";
    "çekoslovakyalaştıramadıkları";
    "çekoslovakyalaştıramadıklarım";
    "çekoslovakyalaştıramadıklarımı";
    "çekoslovakyalaştıramadıklarımız";
    "çekoslovakyalaştıramadıklarımızd";
    "çekoslovakyalaştıramadıklarımızda";
    "çekoslovakyalaştıramadıklarımızdan";
    "çekoslovakyalaştıramadıklarımızdanm";
    "çekoslovakyalaştıramadıklarımızdanmı";
    "çekoslovakyalaştıramadıklarımızdanmıs";
    "çekoslovakyalaştıramadıklarımızdanmısı";
    "çekoslovakyalaştıramadıklarımızdanmısın";
    "çekoslovakyalaştıramadıklarımızdanmısını";
    "çekoslovakyalaştıramadıklarımızdanmısınız";
  |]
]

let test_substring () =
  let test a =
    let m = Array.length a - 1 in
    let v = a.(m) in
    assert(UTF8.length v = m);
    for i = 0 to m do
      assert(a.(i) = UTF8.substring v 0 i);
    done;
    for i = 0 to m - 1 do
      for j = i to m - 1 do
        let u = UTF8.substring v i (j - i + 1) in
        UTF8.validate u
      done
    done
  in
  List.iter test substring_inputs

let () =
  Util.register1 "UTF" "substring" test_substring
