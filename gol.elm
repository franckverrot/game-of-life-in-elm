import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Array exposing (..)
import Task exposing (..)
import Time exposing (Time)

main = program { init          = (initialModel, Cmd.none)
               , update        = update
               , subscriptions = subscriptions
               , view          = view
               }

type CellState = NotAlive
               | Alive

type Msg = StepOver
         | Run
         | Pause
         | Tick Time
         | ChangeState Int Int
         | Reset

type alias Model = { board: Board
                   , run: Bool
                   }
type alias Board = { cells: Array (Array CellState) }

{-| The "glider" and a little glitch in it: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Examples_of_patterns |-}
emptyBoard : Board
emptyBoard = { cells = fromList [ fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive,    Alive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive,    Alive, NotAlive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive,    Alive,    Alive,    Alive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive,    Alive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                , fromList [ NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive, NotAlive ]
                                ]
              }

initialModel : Model
initialModel = { board = emptyBoard, run = True }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    StepOver ->
      (step model, Cmd.none)

    Run ->
      ({model | run = True}, Cmd.none)

    Pause ->
      ({model | run = False}, Cmd.none)

    Tick _ ->
      case model.run of
        True -> (model, Task.succeed StepOver |> Task.perform identity)
        False -> (model, Cmd.none)

    ChangeState x y ->
      (changeAt x y model, Cmd.none)

    Reset ->
      (initialModel, Cmd.none)


changeAt : Int -> Int -> Model -> Model
changeAt x y model =
  let changedRow = Array.get x model.board.cells |> Maybe.withDefault (fromList [])
      newRow = Array.indexedMap (toggleCell y) changedRow
      board = model.board
      newCells = Array.set x newRow board.cells
      newBoard = { board | cells = newCells }
  in
     { model | board = newBoard }

toggleCell targetIndex index st =
  if targetIndex == index then
    case st of
      Alive -> NotAlive
      NotAlive -> Alive
  else
    st

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every 250 Tick

showColumn rowIndex columnIndex column =
  let backgroundColor = if column == Alive then "black" else "white"
  in
    div [onClick (ChangeState rowIndex columnIndex), Html.Attributes.class "grid-item", style [("background-color", backgroundColor)]] [text "."]

showRow rowIndex lst = div [] (List.indexedMap (showColumn rowIndex) (toList lst))

showBoard : Board -> Html Msg
showBoard board =
  let width = board.cells |> Array.length
  in
    div [ Html.Attributes.class "grid-container"
        , style [ ("display", "grid")
                , ("grid-template-columns", (String.repeat width "auto "))
                ]
        ] (List.indexedMap showRow (toList board.cells))

view : Model -> Html Msg
view model =
  div [] [ h1 [] [text "Game of Life"]
         , h2 [] [text "Click to toggle state!"]
         , showBoard model.board
         , button [StepOver |> onClick] [text "Next"]
         , button [Pause |> onClick] [text "Pause"]
         , button [Reset |> onClick] [text "Reset"]
         , button [Run |> onClick] [text "Run"]
         ]

step : Model -> Model
step model = { model | board = evolve model.board }


evolve : Board -> Board
evolve board = { board | cells = Array.indexedMap (evolveRow board) board.cells }

evolveRow : Board -> Int -> Array CellState -> Array CellState
evolveRow board rowIndex lst = Array.indexedMap (evolveColumn board rowIndex) lst

cartesian : List a -> List b -> List (a,b)
cartesian xs ys = List.concatMap (\x -> List.map ( \y -> (x, y) ) ys) xs

evolveColumn : Board -> Int -> Int -> CellState -> CellState
evolveColumn board rowIndex columnIndex st =
  let neighborsPositions = cartesian [-1,0,1] [-1,0,1]
      cellAt cells x y = Array.get x cells
                       |> Maybe.withDefault (fromList [])
                       |> Array.get y
                       |> Maybe.withDefault NotAlive
      cells = neighborsPositions
            |> List.filter ((/=) (0,0))
            |> List.map (\(x, y) -> (rowIndex + x, columnIndex + y))
            |> List.map (
              \(x, y) ->
                cellAt board.cells x y
              )

      aliveNeighbors = List.filter ((==) Alive) cells
                     |> List.length
  in
    case st of
      Alive ->
       if aliveNeighbors < 2 then
         NotAlive
       else if aliveNeighbors == 2 || aliveNeighbors == 3 then
         Alive
       else
         NotAlive

      NotAlive ->
       if (aliveNeighbors == 3) then
         Alive
       else
         NotAlive
