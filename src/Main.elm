module Main exposing (..)

import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string)



-- Parsing Urls


type Page
    = Home
    | Users
    | Clients
    | Login


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map Home (s "home")
        , map Users (s "users")
        , map Clients (s "clients")
        , map Login (s "login")
        ]



-- Model


type Msg
    = Dummy
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavbarMsg Navbar.State


type alias Model =
    { currentPage : Maybe Page
    , navbarState : Navbar.State
    , navKey : Nav.Key
    , url : Url.Url
    }



-- The navbar needs to know the initial window size, so the inital state for a navbar requires a command to be run by the Elm runtime


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( { currentPage = Just Home
      , navbarState = navbarState
      , navKey = key
      , url = url
      }
    , navbarCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavbarMsg state ->
            ( { model | navbarState = state }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | currentPage = Url.Parser.parse routeParser url }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


homePage : Model -> Html Msg
homePage model =
    div [] [ text "home" ]


usersPage : Model -> Html Msg
usersPage model =
    div [] [ text "users" ]


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.currentPage of
                Just Home ->
                    homePage model

                Just Users ->
                    usersPage model

                _ ->
                    homePage model
    in
    { title = "Identity Administration"
    , body =
        [ CDN.stylesheet
        , Navbar.config
            NavbarMsg
            |> Navbar.withAnimation
            |> Navbar.brand [ href "#" ] [ text "Itema" ]
            |> Navbar.items
                [ Navbar.itemLink [ href "/users" ] [ text "Users" ]
                , Navbar.itemLink [ href "/clients" ] [ text "Clients" ]
                ]
            |> Navbar.view model.navbarState
        , content
        ]
    }


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
