port module Main exposing (..)

import Html exposing (Html, button, div, text, span, br)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }



-- Model


type alias Player =
    { authority : Int
    , lastActions : List Int
    }


initPlayer : Player
initPlayer =
    { authority = 50
    , lastActions = []
    }


type alias Model =
    { p1 : Player
    , p2 : Player
    , fullscreen : Maybe Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { p1 = initPlayer
      , p2 = initPlayer
      , fullscreen = Nothing
      }
    , Cmd.none
    )



-- Ports


port activateFullscreen : String -> Cmd msg


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
                        | authority = p1.authority + val
                        , lastActions = (List.append p1.lastActions [ val ])
                    }

                player2 =
                    { p2
                        | lastActions = []
                    }

                m =
                    { model
                        | p1 = player1
                        , p2 = player2
                    }
            in
                ( m, Cmd.none )

        Add val P2 ->
            let
                p2 =
                    model.p2

                p1 =
                    model.p1

                player2 =
                    { p2
                        | authority = p2.authority + val
                        , lastActions = (List.append p2.lastActions [ val ])
                    }

                player1 =
                    { p1 | lastActions = [] }

                m =
                    { model | p2 = player2, p1 = player1 }
            in
                ( m, Cmd.none )

        FullscreenMode on ->
            let
                m =
                    { model | fullscreen = Just on }
            in
                if on then
                    ( m, activateFullscreen "" )
                else
                    ( m, Cmd.none )



-- View


concatLastActions : List Int -> Html Msg
concatLastActions actions =
    div [] (List.map viewLastAction actions)


viewLastAction : Int -> Html Msg
viewLastAction n =
    if n > 0 then
        span [ class "action plus" ] [ text ("+" ++ (toString n)) ]
    else
        span [ class "action minus" ] [ text (toString n) ]


viewButton : Int -> Html Msg
viewButton n =
    let
        valueText =
            if n > 0 then
                ("+" ++ (toString n))
            else
                toString n

        className =
            if n > 0 then
                "plus"
            else
                "minus"
    in
        button [ onClick (Add n P1), class ("button " ++ className) ]
            [ span [] [ text valueText ] ]


viewButtonCol : String -> String -> Html Msg
viewButtonCol className direction =
    let
        player =
            if className == "p1" then
                P1
            else
                P2

        addval : Int -> String -> Int
        addval n direction =
            if direction == "plus" then
                n
            else
                (n * -1)

        textval : Int -> String -> String
        textval n direction =
            if direction == "plus" then
                "+" ++ (toString n)
            else
                toString (n * -1)
    in
        div [ class ("col " ++ className) ]
            [ button [ onClick (Add (addval 1 direction) player), class ("button " ++ direction) ]
                [ span [] [ text (textval 1 direction) ] ]
            , button [ onClick (Add (addval 3 direction) player), class ("button " ++ direction) ]
                [ span [] [ text (textval 3 direction) ] ]
            , button [ onClick (Add (addval 5 direction) player), class ("button " ++ direction) ]
                [ span [] [ text (textval 5 direction) ] ]
            ]


viewFullScreenContainer : Model -> Html Msg
viewFullScreenContainer model =
    case model.fullscreen of
        Nothing ->
            div [ class "fullscreen-confirm" ]
                [ div []
                    [ text "We recommend using this page in fullscreen mode."
                    , br [] []
                    , text "Do you want to activate fullscreen mode now?"
                    , br [] []
                    , button [ onClick (FullscreenMode True) ] [ text "yes" ]
                    , button [ onClick (FullscreenMode False) ] [ text "no" ]
                    ]
                ]

        Just fullscreen ->
            div [] []


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ div [ class "container" ]
            [ viewButtonCol "p1" "minus"
            , viewButtonCol "p1" "plus"
            , div [ class "col middle" ]
                [ div [ class "authority p1" ]
                    [ span [] [ text (toString model.p1.authority) ] ]
                , div [ class "last-actions-container" ]
                    [ div [ class "last-actions p1" ] [ (concatLastActions model.p1.lastActions) ]
                    , div [ class "last-actions p2" ] [ (concatLastActions model.p2.lastActions) ]
                    ]
                , div [ class "authority p2" ]
                    [ span [] [ text (toString model.p2.authority) ] ]
                ]
            , viewButtonCol "p2" "plus"
            , viewButtonCol "p2" "minus"
            ]
        , viewFullScreenContainer model
        ]
