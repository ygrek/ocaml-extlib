

let main =
  Util.log "Extlib tester started..";
  Test_Base64.test ();
  Test_BitSet.test ();
  Test_ExtString.test ();
  Test_ExtList.test ();
  Util.log "\nAll tests completed."
