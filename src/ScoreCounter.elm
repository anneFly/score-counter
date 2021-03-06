port module Main exposing (..)

import Html exposing (Html, button, div, text, span, br, a, input, label, form)
import Html.Events exposing (onClick, onInput, onWithOptions)
import Html.Attributes exposing (class, title, href, value, type_, action, style, attribute)
import Json.Decode as Json


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
    , sound : Bool
    , settingsView : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { p1 = initPlayer
      , p2 = initPlayer
      , fullscreen = False
      , sound = True
      , settingsView = False
      }
    , Cmd.none
    )



-- Ports


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
    | SetSound Bool
    | SettingsView Bool
    | SetScoreP1 String
    | SetScoreP2 String
    | Noop


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

                sound =
                    if model.sound then
                        "on"
                    else
                        "off"
            in
                ( m, playSound sound )

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

                sound =
                    if model.sound then
                        "on"
                    else
                        "off"
            in
                ( m, playSound sound )

        FullscreenMode on ->
            ( { model | fullscreen = on }, Cmd.none )

        SettingsView on ->
            ( { model | settingsView = on }, Cmd.none )

        SetSound on ->
            ( { model | sound = on }, Cmd.none )

        SetScoreP1 val ->
            let
                intVal =
                    case String.toInt val of
                        Err msg ->
                            0

                        Ok val ->
                            val

                p1 =
                    model.p1

                player1 =
                    { p1 | score = intVal }

                m =
                    { model | p1 = player1 }
            in
                ( m, Cmd.none )

        SetScoreP2 val ->
            let
                intVal =
                    case String.toInt val of
                        Err msg ->
                            0

                        Ok val ->
                            val

                p2 =
                    model.p2

                player2 =
                    { p2 | score = intVal }

                m =
                    { model | p2 = player2 }
            in
                ( m, Cmd.none )

        Noop ->
            ( model, Cmd.none )



-- views


fullScreenButton : Model -> Html Msg
fullScreenButton model =
    case model.fullscreen of
        False ->
            a [ onClick (FullscreenMode True), attribute "onClick" "window.activateFullscreen()" ]
                [ span [ class "ion-arrow-expand", title "fullscreen" ] [] ]

        True ->
            a [ onClick (FullscreenMode False), attribute "onClick" "window.deactivateFullscreen()" ]
                [ span [ class "ion-arrow-shrink", title "fullscreen" ] [] ]


soundButton : Model -> Html Msg
soundButton model =
    case model.sound of
        False ->
            a [ onClick (SetSound True) ]
                [ span [ class "ion-android-volume-off", title "sound" ] [] ]

        True ->
            a [ onClick (SetSound False) ]
                [ span [ class "ion-android-volume-up", title "sound" ] [] ]


settingsButton : Model -> Html Msg
settingsButton model =
    a [ onClick (SettingsView True) ]
        [ span [ class "ion-gear-b", title "settings" ] [] ]


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
            [ button [ class "sc-btn", onClick (Add (addval value "minus") player) ]
                [ span [ class "sc-read" ] [ text ("-") ] ]
            , div [ class "sc-count-value" ]
                [ span [ class "sc-read" ] [ text (toString value) ] ]
            , button [ class "sc-btn", onClick (Add (addval value "plus") player) ]
                [ span [ class "sc-read" ] [ text ("+") ] ]
            ]


playerCol : Model -> String -> String -> Html Msg
playerCol model position className =
    div [ class ("sc-col " ++ className) ]
        [ counter position 1
        , score model position
        , counter position 5
        ]


mainView : Model -> Html Msg
mainView model =
    div [ class "sc-container" ]
        [ playerCol model "left" "sc-p-left"
        , div [ class "sc-col sc-middle" ]
            [ soundButton model
            , settingsButton model
            , span
                [ class "sc-spacer" ]
                []
            , fullScreenButton model
            ]
        , playerCol model "right" "sc-p-right"
        ]


onDummySubmit : Html.Attribute Msg
onDummySubmit =
    onWithOptions "submit" { stopPropagation = True, preventDefault = True } (Json.succeed Noop)


settingsView : Model -> Html Msg
settingsView model =
    div [ class "sc-settings-container" ]
        [ span [ class "sc-close-view", onClick (SettingsView False) ]
            [ span [ class "ion-close-round", title "close" ] []
            , text " close"
            ]
        , form [ action "#", onDummySubmit ]
            [ div [ class "sc-set-score" ]
                [ label [] [ text "player 1 starting score" ]
                , input [ type_ "number", onInput (SetScoreP1) ] []
                ]
            , div [ class "sc-set-score" ]
                [ label [] [ text "player 2 starting score" ]
                , input [ type_ "number", onInput (SetScoreP2) ] []
                ]
            ]
        , button [ type_ "submit", style [ ( "position", "absolute" ), ( "left", "-99999px" ), ( "top", "0" ) ] ] [ text "" ]
        ]


view : Model -> Html Msg
view model =
    if model.settingsView == True then
        div [ class "app" ] [ settingsView model ]
    else
        div [ class "app" ] [ mainView model ]
