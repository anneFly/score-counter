port module Main exposing (..)

import Html exposing (Html, button, div, text, span, br, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, title, attribute)


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }



-- Model


type alias Player =
    { score : Int
    , lastChange : Int
    }


initPlayer : Player
initPlayer =
    { score = 20
    , lastChange = 0
    }


type alias Model =
    { p1 : Player
    , p2 : Player
    , fullscreen : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { p1 = initPlayer
      , p2 = initPlayer
      , fullscreen = False
      }
    , Cmd.none
    )



-- Ports


port activateFullscreen : String -> Cmd msg


port deactivateFullscreen : String -> Cmd msg


port playSound : String -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


type PlayerType
    = P1
    | P2


type Msg
    = Add Int PlayerType
    | FullscreenMode Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Add val P1 ->
            let
                p1 =
                    model.p1

                p2 =
                    model.p2

                player1 =
                    { p1
                        | score = p1.score + val
                        , lastChange = p1.lastChange + val
                    }

                player2 =
                    { p2 | lastChange = 0 }

                m =
                    { model
                        | p1 = player1
                        , p2 = player2
                    }
            in
                ( m, playSound "" )

        Add val P2 ->
            let
                p2 =
                    model.p2

                p1 =
                    model.p1

                player2 =
                    { p2
                        | score = p2.score + val
                        , lastChange = p2.lastChange + val
                    }

                player1 =
                    { p1 | lastChange = 0 }

                m =
                    { model | p2 = player2, p1 = player1 }
            in
                ( m, playSound "" )

        FullscreenMode on ->
            let
                m =
                    { model | fullscreen = on }
            in
                if on then
                    ( m, activateFullscreen "" )
                else
                    ( m, deactivateFullscreen "" )



-- views


fullScreenButton : Model -> Html Msg
fullScreenButton model =
    case model.fullscreen of
        False ->
            a [ onClick (FullscreenMode True) ]
                [ span [ class "oi", attribute "data-glyph" "fullscreen-enter", title "fullscreen" ] [] ]

        True ->
            a [ onClick (FullscreenMode False) ]
                [ span [ class "oi", attribute "data-glyph" "fullscreen-exit", title "fullscreen" ] [] ]


lastChange : Int -> Html Msg
lastChange value =
    if value /= 0 then
        span [ class "sc-read" ] [ text (toString value) ]
    else
        span [] []


score : Model -> String -> Html Msg
score model playerPosition =
    let
        player =
            if playerPosition == "left" then
                model.p1
            else
                model.p2
    in
        div [ class "sc-scores" ]
            [ div [ class "sc-score" ]
                [ span [ class "sc-read" ] [ text (toString player.score) ] ]
            , div [ class "sc-last-change" ] [ lastChange player.lastChange ]
            ]


counter : String -> Int -> Html Msg
counter playerPosition value =
    let
        player =
            if playerPosition == "left" then
                P1
            else
                P2

        addval : Int -> String -> Int
        addval n direction =
            if direction == "plus" then
                n
            else
                (n * -1)
    in
        div [ class "sc-counter" ]
            [ button [ onClick (Add (addval value "minus") player) ]
                [ span [ class "sc-read" ] [ text ("-") ] ]
            , div [ class "sc-count-value" ]
                [ span [ class "sc-read" ] [ text (toString value) ] ]
            , button [ onClick (Add (addval value "plus") player) ]
                [ span [ class "sc-read" ] [ text ("+") ] ]
            ]


playerCol : Model -> String -> String -> Html Msg
playerCol model position className =
    div [ class ("sc-col " ++ className) ]
        [ counter position 1
        , score model position
        , counter position 5
        ]


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ div [ class "sc-container" ]
            [ playerCol model "left" "sc-p-left"
            , div [ class "sc-col sc-middle" ]
                [ a []
                    [ span [ class "oi", attribute "data-glyph" "info", title "info" ] [] ]
                , a []
                    [ span [ class "oi", attribute "data-glyph" "question-mark", title "help" ] [] ]
                , span
                    [ class "sc-spacer" ]
                    []
                , a []
                    [ span [ class "oi", attribute "data-glyph" "clock", title "history" ] [] ]
                , a []
                    [ span [ class "oi", attribute "data-glyph" "cog", title "settings" ] [] ]
                , fullScreenButton model
                ]
            , playerCol model "right" "sc-p-right"
            ]
        ]
