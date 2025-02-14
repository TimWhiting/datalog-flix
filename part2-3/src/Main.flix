def main(): Unit \ IO =
    run {
        let relationshipTypes = "parents" :: "parentOf" :: "killed" :: "killedBy" ::
            "serves" :: "servedBy" :: "guardianOf" :: "guardedBy" :: "siblings" ::
            "marriedEngaged" :: "allies" :: Nil;

        let relationships = getRelationships(relationshipTypes);

        let related = inject relationships into Related;

        let rules = #{
            NextDegree(x) :- AlreadyFound(y), Related(y, x), not AlreadyFound(x).
        };
        def degreesOfSeparation(deg: Int32, cs: Vector[String]): Unit \ {IO, Console, FileReadWithResult} = {
                let alreadyFound = inject cs into AlreadyFound;
                let nextDegree = query rules, alreadyFound, related select (x) from NextDegree(x);
                match Vector.length(nextDegree) {
                    case count if count > 0 =>
                        println("Separated by degree ${deg}: ${count}");
                        
                        degreesOfSeparation(deg + 1, Vector.append(cs, nextDegree))
                    case _ =>
                        println("Nobody separated by degree ${deg}")
                }
            };
        degreesOfSeparation(1, List.toVector("Tyrion Lannister" :: Nil))
    } with FileReadWithResult.runWithIO
      with Console.runWithIO