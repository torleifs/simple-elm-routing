module Main exposing (..)

import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url


type Page
    = InputPage


type Msg
    = Dummy
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavbarMsg Navbar.State



-- Model


type alias Model =
    { currentPage : Page
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
    ( { currentPage = InputPage
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
            ( { model | url = url }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
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
        , text (Url.toString model.url)
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
