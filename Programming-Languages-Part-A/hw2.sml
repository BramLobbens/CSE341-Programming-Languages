(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for problem 1 here *)
fun all_except_option (s: string, xs: string list) =
    case xs of
        [] => NONE
        | x :: xs =>
            if same_string(s, x) then
                SOME xs
            else
                case all_except_option(s, xs) of
                    NONE => NONE
                    | SOME ys => SOME (x :: ys)

fun get_substitutions1 (lists: string list list, s: string) =
    case lists of
        [] => [] (* no sublists *)
        | list :: rest =>
            case all_except_option(s, list) of
                NONE => get_substitutions1(rest, s)
                | SOME xs => xs @ get_substitutions1(rest, s)

fun get_substitutions2 (lists: string list list, s: string) =
    let fun rec_helper (lists, acc_list) =
        case lists of
            [] => acc_list (* if no more lists, return the acc_list result *)
            | list :: rest =>
                case all_except_option(s, list) of
                    NONE => rec_helper(rest, acc_list)
                    | SOME xs =>
                    let
                        fun build_list (list, acc_list) =
                            case list of
                                [] => acc_list
                                | x :: xs => build_list(xs, x :: acc_list)
                    in
                        rec_helper(rest, build_list(xs, acc_list)) (* build the acc_list recursively from each item *)
                end
    in
        rec_helper(lists, [])
    end

type fullname = { first: string, middle: string, last: string }
fun similar_names (lists: string list list, fullname: fullname ) =
    case fullname of
        { first = f, middle = m, last = l } =>
            let
                fun make_fullname (xs: string list) = (* helper to build result with record constructs for eacht list item *)
                    case xs of
                        [] => []
                        | x::xs => [{ first=x, middle=m, last=l }] @ make_fullname(xs)
            in
                let val subs = f :: get_substitutions1(lists, f) (* step 1 create a list of substitutions by fullname's first name *)
                in
                    make_fullname(subs)
                end
            end

(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw

exception IllegalMove

(* put your solutions for problem 2 here *)
fun card_color (suit, _) =
    case suit of
        Clubs => Black
        | Spades => Black
        | _ => Red

fun card_value (_, rank) =
    case rank of
        Num(i) => i
        | Ace => 11
        | _ => 10

fun remove_card (cs: card list, c: card, e: exn) =
    let
        fun helper (xs, acc) =
            case xs of
                [] => raise e
                | x::xs' => if (x = c) then acc @ xs'
                            else helper (xs', x::acc)
    in
        helper (cs, [])
    end

fun all_same_color [] = true
    | all_same_color (_::[]) = true
    | all_same_color (card1::(card2::tl)) =
        card_color card1 = card_color card2 andalso all_same_color(card2::tl)

fun sum_cards (cards: card list) =
    let
        fun helper (cs, acc) =
            case cs of
                [] => acc
                | card::tl => helper (tl, acc + (card_value card))
    in
        helper (cards, 0)
    end

fun score (cards, goal) =
    let
        val sum = sum_cards cards
        val preliminary_score = if sum > goal
                                then 3 * (sum - goal)
                                else goal - sum
    in
        if all_same_color cards
        then preliminary_score div 2
        else preliminary_score
    end

fun officiate (cards, moves, goal) =
    let
        fun helper (cards', moves', held_cards) =
            case moves' of
                [] => score(held_cards, goal)
                | (move::rest_moves) =>
                    case move of
                        Discard(card) =>
                            let
                                val new_hand = remove_card(held_cards, card, IllegalMove)
                            in
                                helper (cards', rest_moves, new_hand)
                            end
                        | Draw =>
                            let
                                fun goal_exceeded new_hand = (sum_cards new_hand) > goal
                            in
                                case cards' of
                                    [] => score(held_cards, goal)
                                    | card::cards'' =>
                                        let val new_hand = card::held_cards
                                        in
                                            if (goal_exceeded new_hand)
                                            then score(new_hand, goal)
                                            else helper (cards'', rest_moves, new_hand)
                                        end
                            end
    in
        helper (cards, moves, [])
    end