module Styles exposing (..)


logo : List ( String, String )
logo =
    [ ( "display", "inline-block" ), ( "width", "257px" ), ( "height", "88px" ), ( "background-size", " 257px 88px" ) ]


tracking : List ( String, String )
tracking =
    [ ( "background-color", "#eee" ), ( "padding-left", "48px" ), ( "padding-right", "48px" ) ]


control : String -> String
control str =
    str ++ " w3-bar-item w3-border w3-border-orange w3-hover-border-navy w3-round-large  w3-margin-right w3-deep-orange"


row : String
row =
    "w3-row"


colS1 : String
colS1 =
    "w3-col s1"


colS2 : String
colS2 =
    "w3-col s2"


colS4 : String -> String
colS4 str =
    "w3-col s4 " ++ str


colS8 : String -> String
colS8 str =
    "w3-col s8 " ++ str


colS10 : String
colS10 =
    "w3-col s10"


buttonClassStr : String -> String
buttonClassStr str =
    "w3-button w3-round-large w3-deep-orange w3-border-orange w3-hover-border-navy " ++ str
