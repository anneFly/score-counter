module Main exposing (..)

import Html exposing (Html, button, div, text, span)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- Model


type alias Player =
    { authority : Int
    , lastActions : List Int
    }


init : Player
init =
    { authority = 50
    , lastActions = []
    }


type alias Model =
    { p1 : Player
    , p2 : Player
    }


model : Model
model =
    { p1 = init
    , p2 = init
    }



-- Update


type PlayerType
    = P1
    | P2


type Msg
    = Add Int PlayerType


update : Msg -> Model -> Model
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
            in
                { model
                    | p1 = player1
                    , p2 = player2
                }

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
            in
                { model | p2 = player2, p1 = player1 }



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


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "col p1" ]
            [ button [ onClick (Add -1 P1), class "button minus" ]
                [ span [] [ text "-1" ] ]
            , button [ onClick (Add -3 P1), class "button minus" ]
                [ span [] [ text "-3" ] ]
            , button [ onClick (Add -5 P1), class "button minus" ]
                [ span [] [ text "-5" ] ]
            ]
        , div [ class "col p1" ]
            [ button [ onClick (Add 1 P1), class "button plus" ]
                [ span [] [ text "+1" ] ]
            , button [ onClick (Add 3 P1), class "button plus" ]
                [ span [] [ text "+3" ] ]
            , button [ onClick (Add 5 P1), class "button plus" ]
                [ span [] [ text "+5" ] ]
            ]
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
        , div [ class "col p2" ]
            [ button [ onClick (Add 1 P2), class "button plus" ]
                [ span [] [ text "+1" ] ]
            , button [ onClick (Add 3 P2), class "button plus" ]
                [ span [] [ text "+3" ] ]
            , button [ onClick (Add 5 P2), class "button plus" ]
                [ span [] [ text "+5" ] ]
            ]
        , div [ class "col p2" ]
            [ button [ onClick (Add -1 P2), class "button minus" ]
                [ span [] [ text "-1" ] ]
            , button [ onClick (Add -3 P2), class "button minus" ]
                [ span [] [ text "-3" ] ]
            , button [ onClick (Add -5 P2), class "button minus" ]
                [ span [] [ text "-5" ] ]
            ]
        ]
