use Down.Down

def main(): Unit \ IO =
    run {
        let relationshipTypes = "parents" :: "parentOf" :: "killed" :: "killedBy" ::
            "serves" :: "servedBy" :: "guardianOf" :: "guardedBy" :: "siblings" ::
            "marriedEngaged" :: "allies" :: Nil;
        let relationships = getRelationships(relationshipTypes);

        let related = inject relationships into Related;

        let rules = #{
            Degree(x; Down(0)) :- Root(x).
            Degree(x; n + Down(1)) :- Degree(y; n), Related(y, x).
            AggregatedDegree(n; Set#{x}) :- fix Degree(x; n).
            DegreeCount(n, Set.size(s)) :- fix AggregatedDegree(n; s).
        };

        let root = inject "Tyrion Lannister" :: Nil into Root;

        query rules, related, root select (d, c) from DegreeCount(d, c) |>
            Vector.forEach(match (d, c) -> println("Separated by degree ${d}: ${c}"))
    } with FileReadWithResult.runWithIO
      with Console.runWithIO