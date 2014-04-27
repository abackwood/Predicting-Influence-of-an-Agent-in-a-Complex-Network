globals [runs iteration dominant_lexicon]
turtles-own [lexicon original_lexicon successes suggestions_x1 suggestions_partlex suggestions_ce per_run_influence]

;; Setup
to setup-network
  clear-turtles
  set-default-shape turtles "circle"
  setup-topology
  ask turtles [
    set color green
  ]
  layout-radial turtles links turtle central_turtle
  ask patches [ set pcolor black ]
end

to setup_runs
  setup-network
  set runs 0
  ask turtles [
    set per_run_influence []
  ]
end

to setup
  set iteration 0
  set dominant_lexicon []
  ask turtles [
    set lexicon (shuffle [1 2 3 4 5 6 7 8 9 10])  ;; random mappings in lexicon
    set original_lexicon lexicon  ;; Save the original lexicon so it can be compared against the dominant one later
    set successes []
    set suggestions_x1 []
    set suggestions_partlex []
    set suggestions_ce []
  ]
end

;; Main execution
to go
  if runs = num_of_runs [
    clear-output
    output-print num_of_runs
    output-print max_iterations
    output-print p_broadcast
    output-print p_update
    ask turtles [
      let i 0
      output-print (word who " " (mean per_run_influence))
    ]
    export-output (word "Graph_" (count turtles) "_influence.txt")
    stop
  ]
  set runs (runs + 1)
  
  setup
  while [ iteration < max_iterations ] [
    do_round
    set iteration (iteration + 1)
  ]
  ask turtles [
    set per_run_influence (lput influence per_run_influence)
  ]
end

to do_round
  ask turtles [
    set successes (filter [? < iteration - 20] successes)  ;; Update the success list.
    ;; Step 1: Send mapping to random neighbour. Add to successes if identical mapping
    let idx (int random 10)
    let mapping (item idx lexicon)
    let succes? 0
    ask one-of link-neighbors [
      if mapping = item idx lexicon [ set succes? 1 ]
    ]
    if succes? = 1 [ set successes (lput iteration successes) ]
  ]
  ask turtles [
    ;; Step 2: Chance of p_broadcast to send mapping to all neighbours
    if random-float 1 < p_broadcast [
      let x1 random 10
      let x2 (x1 + random (11 - x1))
      let partialLexicon (sublist lexicon x1 x2)
      ask link-neighbors [
        set suggestions_x1 (lput x1 suggestions_x1)
        set suggestions_partlex (lput partialLexicon suggestions_partlex)
        set suggestions_ce (lput ([comm_eff] of myself) suggestions_ce)
      ]
    ]
  ]
  
  ask turtles [
    ;; Step 3: Chance of p_update to change mapping. Biggest Communicative Efficacy wins
    if length suggestions_partlex > 0 and random-float 1 < p_update [
      let highest_ce -1
      let x1 -1
      let partlex -1
      (foreach suggestions_x1 suggestions_partlex suggestions_ce [
          if ?3 > highest_ce [
            set x1 ?1
            set partlex ?2
            set highest_ce ?3
          ]
      ])
      set lexicon (sentence (sublist lexicon 0 x1) partlex (sublist lexicon (x1 + length partlex) 10))  ;; Use two-point crossover to update lexicon
    ]
    set suggestions_x1 []  ;; Clear out all suggestions
    set suggestions_partlex []
    set suggestions_ce []
  ]
  
  if iteration mod 1000 = 0 [
    clear-output
    find_dominant_lexicon
    ask turtles [
      set color (scale-color green influence 0 1)
      ;;output-show lexicon
    ]
  ]
end

to find_dominant_lexicon  ;; Calculate and update the dominant lexicon based on current lexicons
  let all_lexicons []
  let num_lexicons []
  ask turtles [
    let i 0
    let found false
    foreach all_lexicons [
      if lexicon = ? [
        set num_lexicons (replace-item i num_lexicons (item i num_lexicons + 1))
        set found true
      ]
      set i (i + 1)
    ]
    if found = false [
      set all_lexicons (lput lexicon all_lexicons)
      set num_lexicons (lput 1 num_lexicons)
    ]
  ]
  if show_lexicons [
    (foreach all_lexicons num_lexicons [
        output-print (word ?1 ": " ?2)
    ])
  ]
  
  let i 0
  let maxi 0
  foreach num_lexicons [
    if ? > item maxi num_lexicons [ set maxi i ]
    set i (i + 1)
  ]
  set dominant_lexicon (item maxi all_lexicons)
end


;; Turtle reports
to-report influence
  let intersection 0
  let union 10
  (foreach original_lexicon dominant_lexicon [
      if ?1 = ?2 [ set intersection (intersection + 1) ]
  ])
  (foreach original_lexicon dominant_lexicon [
      if ?1 != ?2 [ set union (union + 1) ]
  ])
  report intersection / union
end

to-report comm_eff
  report length successes
end

;; Network topology
to setup-topology
create-turtles 200
ask turtle 100 [ create-links-with (turtle-set turtle 96 turtle 176 turtle 103 turtle 83 turtle 138 turtle 173 turtle 149 turtle 7 ) ]
ask turtle 63 [ create-links-with (turtle-set turtle 199 ) ]
ask turtle 31 [ create-links-with (turtle-set turtle 53 turtle 163 turtle 179 turtle 137 turtle 28 turtle 95 turtle 9 ) ]
ask turtle 40 [ create-links-with (turtle-set turtle 15 turtle 169 turtle 107 turtle 46 turtle 77 ) ]
ask turtle 95 [ create-links-with (turtle-set turtle 27 turtle 7 turtle 21 turtle 31 turtle 0 turtle 74 turtle 12 ) ]
ask turtle 128 [ create-links-with (turtle-set turtle 97 turtle 77 turtle 123 ) ]
ask turtle 116 [ create-links-with (turtle-set turtle 195 turtle 162 turtle 25 turtle 105 turtle 198 turtle 159 turtle 169 turtle 178 turtle 74 turtle 136 turtle 0 ) ]
ask turtle 151 [ create-links-with (turtle-set turtle 23 turtle 145 turtle 53 turtle 22 turtle 164 turtle 62 turtle 67 turtle 153 turtle 25 turtle 115 turtle 82 ) ]
ask turtle 184 [ create-links-with (turtle-set turtle 10 turtle 130 turtle 176 turtle 56 turtle 83 turtle 181 turtle 122 turtle 160 turtle 94 ) ]
ask turtle 58 [ create-links-with (turtle-set turtle 7 turtle 43 turtle 114 turtle 18 turtle 133 turtle 105 turtle 178 turtle 141 turtle 120 turtle 64 turtle 176 turtle 66 turtle 138 ) ]
ask turtle 60 [ create-links-with (turtle-set turtle 16 turtle 153 turtle 197 turtle 65 ) ]
ask turtle 186 [ create-links-with (turtle-set turtle 64 turtle 164 turtle 142 turtle 71 turtle 57 turtle 25 turtle 22 turtle 179 turtle 129 turtle 172 ) ]
ask turtle 30 [ create-links-with (turtle-set turtle 187 turtle 77 turtle 39 turtle 196 turtle 1 turtle 164 turtle 168 ) ]
ask turtle 135 [ create-links-with (turtle-set turtle 114 turtle 96 turtle 134 turtle 197 turtle 84 ) ]
ask turtle 193 [ create-links-with (turtle-set turtle 20 turtle 33 turtle 39 turtle 192 ) ]
ask turtle 51 [ create-links-with (turtle-set turtle 53 turtle 27 turtle 75 turtle 169 turtle 111 turtle 12 turtle 144 turtle 7 turtle 59 turtle 173 turtle 14 turtle 69 turtle 65 turtle 45 ) ]
ask turtle 152 [ create-links-with (turtle-set turtle 161 turtle 199 turtle 129 turtle 125 turtle 163 turtle 69 turtle 77 turtle 92 turtle 101 turtle 194 turtle 50 turtle 83 ) ]
ask turtle 23 [ create-links-with (turtle-set turtle 151 turtle 21 turtle 199 turtle 136 turtle 55 turtle 173 ) ]
ask turtle 37 [ create-links-with (turtle-set turtle 42 turtle 81 turtle 112 turtle 4 ) ]
ask turtle 49 [ create-links-with (turtle-set turtle 67 turtle 90 turtle 124 turtle 106 turtle 83 turtle 103 turtle 94 ) ]
ask turtle 7 [ create-links-with (turtle-set turtle 179 turtle 58 turtle 95 turtle 22 turtle 64 turtle 56 turtle 1 turtle 51 turtle 24 turtle 65 turtle 180 turtle 100 turtle 70 turtle 91 ) ]
ask turtle 179 [ create-links-with (turtle-set turtle 7 turtle 146 turtle 94 turtle 62 turtle 192 turtle 31 turtle 67 turtle 144 turtle 45 turtle 171 turtle 181 turtle 29 turtle 43 turtle 186 ) ]
ask turtle 169 [ create-links-with (turtle-set turtle 173 turtle 189 turtle 51 turtle 112 turtle 40 turtle 53 turtle 116 turtle 108 turtle 22 turtle 91 turtle 107 turtle 19 turtle 105 ) ]
ask turtle 72 [ create-links-with (turtle-set turtle 183 turtle 0 turtle 57 ) ]
ask turtle 2 [ create-links-with (turtle-set turtle 133 ) ]
ask turtle 36 [ create-links-with (turtle-set turtle 175 turtle 180 turtle 163 turtle 27 turtle 57 turtle 89 turtle 101 turtle 142 turtle 62 ) ]
ask turtle 198 [ create-links-with (turtle-set turtle 187 turtle 185 turtle 41 turtle 116 turtle 129 turtle 147 turtle 38 ) ]
ask turtle 42 [ create-links-with (turtle-set turtle 139 turtle 197 turtle 9 turtle 161 turtle 173 turtle 165 turtle 37 turtle 53 turtle 62 turtle 90 turtle 150 turtle 174 turtle 78 turtle 102 ) ]
ask turtle 33 [ create-links-with (turtle-set turtle 21 turtle 129 turtle 103 turtle 19 turtle 193 turtle 64 turtle 142 turtle 69 turtle 66 turtle 96 turtle 105 turtle 115 turtle 0 ) ]
ask turtle 82 [ create-links-with (turtle-set turtle 32 turtle 10 turtle 151 turtle 56 ) ]
ask turtle 131 [ create-links-with (turtle-set turtle 149 turtle 137 turtle 180 turtle 112 turtle 75 turtle 89 turtle 174 turtle 65 turtle 55 turtle 199 turtle 21 turtle 27 ) ]
ask turtle 54 [ create-links-with (turtle-set turtle 92 turtle 129 turtle 137 turtle 114 turtle 180 turtle 77 turtle 75 turtle 35 turtle 172 ) ]
ask turtle 32 [ create-links-with (turtle-set turtle 82 turtle 121 turtle 190 turtle 143 turtle 97 turtle 171 turtle 123 turtle 147 turtle 114 turtle 17 ) ]
ask turtle 136 [ create-links-with (turtle-set turtle 103 turtle 48 turtle 161 turtle 23 turtle 55 turtle 116 ) ]
ask turtle 171 [ create-links-with (turtle-set turtle 139 turtle 16 turtle 143 turtle 157 turtle 56 turtle 78 turtle 32 turtle 38 turtle 179 ) ]
ask turtle 108 [ create-links-with (turtle-set turtle 14 turtle 178 turtle 138 turtle 25 turtle 197 turtle 157 turtle 192 turtle 169 turtle 148 turtle 71 turtle 88 ) ]
ask turtle 94 [ create-links-with (turtle-set turtle 28 turtle 179 turtle 168 turtle 165 turtle 77 turtle 139 turtle 39 turtle 163 turtle 49 turtle 14 turtle 17 turtle 184 turtle 122 ) ]
ask turtle 52 [ create-links-with (turtle-set turtle 130 turtle 125 turtle 75 turtle 148 turtle 74 turtle 133 turtle 88 turtle 12 turtle 159 turtle 114 ) ]
ask turtle 168 [ create-links-with (turtle-set turtle 178 turtle 139 turtle 39 turtle 94 turtle 199 turtle 77 turtle 55 turtle 153 turtle 110 turtle 38 turtle 195 turtle 30 turtle 97 ) ]
ask turtle 189 [ create-links-with (turtle-set turtle 70 turtle 169 ) ]
ask turtle 187 [ create-links-with (turtle-set turtle 198 turtle 161 turtle 83 turtle 68 turtle 25 turtle 30 turtle 165 turtle 182 turtle 181 turtle 3 turtle 67 ) ]
ask turtle 44 [ create-links-with (turtle-set turtle 153 turtle 74 turtle 4 turtle 66 turtle 35 turtle 90 turtle 196 turtle 161 ) ]
ask turtle 45 [ create-links-with (turtle-set turtle 9 turtle 185 turtle 130 turtle 153 turtle 57 turtle 192 turtle 179 turtle 114 turtle 51 ) ]
ask turtle 88 [ create-links-with (turtle-set turtle 39 turtle 120 turtle 195 turtle 52 turtle 142 turtle 108 ) ]
ask turtle 59 [ create-links-with (turtle-set turtle 89 turtle 142 turtle 75 turtle 92 turtle 117 turtle 96 turtle 93 turtle 114 turtle 106 turtle 62 turtle 64 turtle 51 turtle 47 ) ]
ask turtle 65 [ create-links-with (turtle-set turtle 12 turtle 79 turtle 35 turtle 129 turtle 131 turtle 57 turtle 7 turtle 51 turtle 80 turtle 62 turtle 60 turtle 197 ) ]
ask turtle 15 [ create-links-with (turtle-set turtle 120 turtle 146 turtle 34 turtle 16 turtle 40 turtle 167 turtle 180 turtle 25 ) ]
ask turtle 145 [ create-links-with (turtle-set turtle 151 turtle 98 turtle 38 turtle 162 ) ]
ask turtle 104 [ create-links-with (turtle-set turtle 149 turtle 56 turtle 81 turtle 153 ) ]
ask turtle 115 [ create-links-with (turtle-set turtle 196 turtle 154 turtle 4 turtle 151 turtle 74 turtle 33 turtle 167 turtle 18 ) ]
ask turtle 195 [ create-links-with (turtle-set turtle 116 turtle 123 turtle 178 turtle 137 turtle 88 turtle 11 turtle 165 turtle 98 turtle 106 turtle 168 ) ]
ask turtle 107 [ create-links-with (turtle-set turtle 40 turtle 71 turtle 169 ) ]
ask turtle 61 [ create-links-with (turtle-set turtle 69 ) ]
ask turtle 56 [ create-links-with (turtle-set turtle 199 turtle 7 turtle 171 turtle 104 turtle 149 turtle 184 turtle 81 turtle 93 turtle 82 turtle 143 ) ]
ask turtle 197 [ create-links-with (turtle-set turtle 34 turtle 42 turtle 135 turtle 103 turtle 114 turtle 38 turtle 108 turtle 1 turtle 137 turtle 60 turtle 84 turtle 101 turtle 91 turtle 65 ) ]
ask turtle 149 [ create-links-with (turtle-set turtle 89 turtle 104 turtle 131 turtle 176 turtle 161 turtle 112 turtle 56 turtle 28 turtle 102 turtle 47 turtle 100 turtle 81 turtle 43 turtle 83 ) ]
ask turtle 126 [ create-links-with (turtle-set turtle 47 ) ]
ask turtle 34 [ create-links-with (turtle-set turtle 197 turtle 15 turtle 106 turtle 167 turtle 191 turtle 74 ) ]
ask turtle 177 [ create-links-with (turtle-set turtle 79 turtle 12 ) ]
ask turtle 148 [ create-links-with (turtle-set turtle 98 turtle 133 turtle 144 turtle 38 turtle 53 turtle 75 turtle 52 turtle 57 turtle 92 turtle 138 turtle 108 turtle 117 turtle 12 ) ]
ask turtle 146 [ create-links-with (turtle-set turtle 179 turtle 15 turtle 92 turtle 165 turtle 9 turtle 55 turtle 159 turtle 53 turtle 69 turtle 19 ) ]
ask turtle 142 [ create-links-with (turtle-set turtle 59 turtle 130 turtle 117 turtle 122 turtle 1 turtle 186 turtle 33 turtle 88 turtle 36 ) ]
ask turtle 123 [ create-links-with (turtle-set turtle 81 turtle 10 turtle 157 turtle 122 turtle 138 turtle 25 turtle 32 turtle 195 turtle 154 turtle 18 turtle 128 ) ]
ask turtle 156 [ create-links-with (turtle-set turtle 39 ) ]
ask turtle 62 [ create-links-with (turtle-set turtle 98 turtle 165 turtle 179 turtle 89 turtle 158 turtle 151 turtle 153 turtle 42 turtle 59 turtle 65 turtle 20 turtle 36 ) ]
ask turtle 121 [ create-links-with (turtle-set turtle 32 ) ]
ask turtle 181 [ create-links-with (turtle-set turtle 113 turtle 89 turtle 187 turtle 179 turtle 120 turtle 184 turtle 102 turtle 163 ) ]
ask turtle 140 [ create-links-with (turtle-set turtle 112 ) ]
ask turtle 21 [ create-links-with (turtle-set turtle 33 turtle 95 turtle 23 turtle 38 turtle 28 turtle 131 turtle 164 turtle 165 ) ]
ask turtle 19 [ create-links-with (turtle-set turtle 147 turtle 119 turtle 33 turtle 133 turtle 46 turtle 146 turtle 169 ) ]
ask turtle 164 [ create-links-with (turtle-set turtle 129 turtle 151 turtle 186 turtle 147 turtle 21 turtle 30 turtle 83 ) ]
ask turtle 16 [ create-links-with (turtle-set turtle 171 turtle 15 turtle 85 turtle 60 turtle 29 ) ]
ask turtle 103 [ create-links-with (turtle-set turtle 9 turtle 136 turtle 33 turtle 197 turtle 100 turtle 196 turtle 49 turtle 167 turtle 74 ) ]
ask turtle 70 [ create-links-with (turtle-set turtle 189 turtle 157 turtle 7 ) ]
ask turtle 122 [ create-links-with (turtle-set turtle 77 turtle 180 turtle 123 turtle 196 turtle 142 turtle 91 turtle 55 turtle 158 turtle 129 turtle 184 turtle 94 ) ]
ask turtle 175 [ create-links-with (turtle-set turtle 36 turtle 99 turtle 113 ) ]
ask turtle 130 [ create-links-with (turtle-set turtle 52 turtle 45 turtle 184 turtle 142 turtle 80 turtle 153 turtle 57 turtle 97 ) ]
ask turtle 86 [ create-links-with (turtle-set turtle 11 turtle 74 turtle 10 turtle 73 turtle 9 turtle 77 ) ]
ask turtle 159 [ create-links-with (turtle-set turtle 66 turtle 109 turtle 146 turtle 116 turtle 52 turtle 188 turtle 147 turtle 46 ) ]
ask turtle 99 [ create-links-with (turtle-set turtle 87 turtle 141 turtle 12 turtle 174 turtle 143 turtle 196 turtle 155 turtle 175 turtle 106 turtle 55 turtle 178 turtle 39 ) ]
ask turtle 91 [ create-links-with (turtle-set turtle 14 turtle 89 turtle 122 turtle 169 turtle 197 turtle 7 ) ]
ask turtle 92 [ create-links-with (turtle-set turtle 54 turtle 59 turtle 146 turtle 112 turtle 22 turtle 109 turtle 148 turtle 55 turtle 152 turtle 133 ) ]
ask turtle 161 [ create-links-with (turtle-set turtle 187 turtle 152 turtle 22 turtle 47 turtle 149 turtle 166 turtle 67 turtle 136 turtle 42 turtle 53 turtle 44 turtle 120 turtle 147 ) ]
ask turtle 93 [ create-links-with (turtle-set turtle 74 turtle 154 turtle 59 turtle 97 turtle 64 turtle 105 turtle 84 turtle 56 turtle 66 turtle 194 ) ]
ask turtle 17 [ create-links-with (turtle-set turtle 188 turtle 11 turtle 157 turtle 94 turtle 32 ) ]
ask turtle 185 [ create-links-with (turtle-set turtle 198 turtle 45 turtle 27 turtle 89 ) ]
ask turtle 129 [ create-links-with (turtle-set turtle 152 turtle 139 turtle 33 turtle 164 turtle 54 turtle 65 turtle 198 turtle 122 turtle 111 turtle 186 turtle 188 ) ]
ask turtle 124 [ create-links-with (turtle-set turtle 3 turtle 49 ) ]
ask turtle 38 [ create-links-with (turtle-set turtle 148 turtle 12 turtle 21 turtle 172 turtle 80 turtle 145 turtle 83 turtle 197 turtle 171 turtle 194 turtle 47 turtle 198 turtle 168 ) ]
ask turtle 84 [ create-links-with (turtle-set turtle 125 turtle 135 turtle 93 turtle 197 ) ]
ask turtle 13 [ create-links-with (turtle-set turtle 74 ) ]
ask turtle 22 [ create-links-with (turtle-set turtle 161 turtle 7 turtle 71 turtle 92 turtle 151 turtle 106 turtle 97 turtle 186 turtle 169 turtle 125 ) ]
ask turtle 176 [ create-links-with (turtle-set turtle 149 turtle 100 turtle 196 turtle 184 turtle 199 turtle 191 turtle 58 ) ]
ask turtle 5 [ create-links-with (turtle-set turtle 137 turtle 141 ) ]
ask turtle 117 [ create-links-with (turtle-set turtle 163 turtle 59 turtle 194 turtle 155 turtle 142 turtle 137 turtle 148 ) ]
ask turtle 77 [ create-links-with (turtle-set turtle 122 turtle 30 turtle 39 turtle 168 turtle 94 turtle 54 turtle 160 turtle 68 turtle 152 turtle 192 turtle 128 turtle 40 turtle 112 turtle 86 ) ]
ask turtle 26 [ create-links-with (turtle-set turtle 118 turtle 83 turtle 138 turtle 166 ) ]
ask turtle 68 [ create-links-with (turtle-set turtle 187 turtle 77 ) ]
ask turtle 47 [ create-links-with (turtle-set turtle 39 turtle 161 turtle 57 turtle 149 turtle 38 turtle 0 turtle 67 turtle 126 turtle 113 turtle 59 ) ]
ask turtle 96 [ create-links-with (turtle-set turtle 100 turtle 134 turtle 135 turtle 59 turtle 18 turtle 106 turtle 105 turtle 33 turtle 167 ) ]
ask turtle 143 [ create-links-with (turtle-set turtle 171 turtle 39 turtle 32 turtle 99 turtle 190 turtle 20 turtle 56 ) ]
ask turtle 64 [ create-links-with (turtle-set turtle 69 turtle 7 turtle 133 turtle 186 turtle 144 turtle 93 turtle 33 turtle 59 turtle 0 turtle 3 turtle 58 ) ]
ask turtle 183 [ create-links-with (turtle-set turtle 72 turtle 196 ) ]
ask turtle 55 [ create-links-with (turtle-set turtle 75 turtle 101 turtle 192 turtle 172 turtle 146 turtle 168 turtle 131 turtle 122 turtle 99 turtle 23 turtle 136 turtle 92 turtle 112 ) ]
ask turtle 166 [ create-links-with (turtle-set turtle 29 turtle 161 turtle 192 turtle 153 turtle 109 turtle 105 turtle 26 turtle 97 ) ]
ask turtle 83 [ create-links-with (turtle-set turtle 187 turtle 112 turtle 4 turtle 14 turtle 26 turtle 29 turtle 38 turtle 49 turtle 100 turtle 184 turtle 164 turtle 152 turtle 149 ) ]
ask turtle 173 [ create-links-with (turtle-set turtle 157 turtle 80 turtle 3 turtle 169 turtle 42 turtle 51 turtle 81 turtle 14 turtle 23 turtle 67 turtle 100 ) ]
ask turtle 0 [ create-links-with (turtle-set turtle 3 turtle 105 turtle 196 turtle 72 turtle 64 turtle 95 turtle 47 turtle 165 turtle 43 turtle 116 turtle 33 ) ]
ask turtle 11 [ create-links-with (turtle-set turtle 86 turtle 71 turtle 17 turtle 195 turtle 114 turtle 112 ) ]
ask turtle 194 [ create-links-with (turtle-set turtle 87 turtle 50 turtle 117 turtle 80 turtle 105 turtle 38 turtle 75 turtle 152 turtle 188 turtle 93 ) ]
ask turtle 174 [ create-links-with (turtle-set turtle 99 turtle 131 turtle 42 ) ]
ask turtle 119 [ create-links-with (turtle-set turtle 19 ) ]
ask turtle 25 [ create-links-with (turtle-set turtle 41 turtle 187 turtle 116 turtle 123 turtle 108 turtle 29 turtle 112 turtle 151 turtle 186 turtle 15 turtle 199 ) ]
ask turtle 153 [ create-links-with (turtle-set turtle 139 turtle 44 turtle 45 turtle 157 turtle 46 turtle 168 turtle 114 turtle 188 turtle 166 turtle 62 turtle 151 turtle 60 turtle 130 turtle 104 ) ]
ask turtle 89 [ create-links-with (turtle-set turtle 149 turtle 59 turtle 91 turtle 131 turtle 62 turtle 181 turtle 39 turtle 36 turtle 185 turtle 118 ) ]
ask turtle 97 [ create-links-with (turtle-set turtle 80 turtle 128 turtle 69 turtle 93 turtle 32 turtle 138 turtle 22 turtle 130 turtle 81 turtle 166 turtle 167 turtle 90 turtle 168 ) ]
ask turtle 133 [ create-links-with (turtle-set turtle 148 turtle 8 turtle 114 turtle 80 turtle 101 turtle 64 turtle 2 turtle 58 turtle 19 turtle 52 turtle 165 turtle 92 turtle 102 ) ]
ask turtle 163 [ create-links-with (turtle-set turtle 117 turtle 172 turtle 31 turtle 152 turtle 75 turtle 120 turtle 53 turtle 192 turtle 50 turtle 48 turtle 36 turtle 105 turtle 94 turtle 181 ) ]
ask turtle 74 [ create-links-with (turtle-set turtle 93 turtle 13 turtle 44 turtle 86 turtle 102 turtle 52 turtle 80 turtle 95 turtle 115 turtle 116 turtle 34 turtle 103 turtle 28 ) ]
ask turtle 112 [ create-links-with (turtle-set turtle 199 turtle 138 turtle 83 turtle 92 turtle 149 turtle 131 turtle 169 turtle 140 turtle 25 turtle 137 turtle 11 turtle 55 turtle 37 turtle 77 ) ]
ask turtle 102 [ create-links-with (turtle-set turtle 29 turtle 74 turtle 46 turtle 149 turtle 39 turtle 157 turtle 133 turtle 181 turtle 42 ) ]
ask turtle 73 [ create-links-with (turtle-set turtle 86 ) ]
ask turtle 180 [ create-links-with (turtle-set turtle 114 turtle 122 turtle 131 turtle 53 turtle 36 turtle 54 turtle 15 turtle 138 turtle 7 turtle 110 ) ]
ask turtle 10 [ create-links-with (turtle-set turtle 184 turtle 123 turtle 86 turtle 82 turtle 125 ) ]
ask turtle 150 [ create-links-with (turtle-set turtle 172 turtle 113 turtle 76 turtle 42 turtle 144 ) ]
ask turtle 182 [ create-links-with (turtle-set turtle 187 ) ]
ask turtle 87 [ create-links-with (turtle-set turtle 99 turtle 194 turtle 57 turtle 192 turtle 157 turtle 134 ) ]
ask turtle 114 [ create-links-with (turtle-set turtle 66 turtle 180 turtle 135 turtle 133 turtle 58 turtle 54 turtle 59 turtle 153 turtle 197 turtle 11 turtle 45 turtle 52 turtle 32 turtle 196 ) ]
ask turtle 106 [ create-links-with (turtle-set turtle 160 turtle 101 turtle 34 turtle 49 turtle 99 turtle 22 turtle 59 turtle 75 turtle 96 turtle 3 turtle 195 turtle 137 ) ]
ask turtle 57 [ create-links-with (turtle-set turtle 45 turtle 87 turtle 144 turtle 188 turtle 148 turtle 47 turtle 65 turtle 36 turtle 186 turtle 130 turtle 72 turtle 29 ) ]
ask turtle 127 [ create-links-with (turtle-set turtle 147 ) ]
ask turtle 162 [ create-links-with (turtle-set turtle 116 turtle 71 turtle 145 ) ]
ask turtle 139 [ create-links-with (turtle-set turtle 168 turtle 153 turtle 171 turtle 129 turtle 42 turtle 94 ) ]
ask turtle 191 [ create-links-with (turtle-set turtle 176 turtle 34 ) ]
ask turtle 41 [ create-links-with (turtle-set turtle 25 turtle 9 turtle 198 turtle 196 turtle 12 turtle 28 ) ]
ask turtle 8 [ create-links-with (turtle-set turtle 133 turtle 69 turtle 90 ) ]
ask turtle 24 [ create-links-with (turtle-set turtle 7 ) ]
ask turtle 39 [ create-links-with (turtle-set turtle 47 turtle 168 turtle 105 turtle 77 turtle 143 turtle 156 turtle 79 turtle 30 turtle 88 turtle 193 turtle 94 turtle 89 turtle 102 turtle 99 ) ]
ask turtle 170 [ create-links-with (turtle-set turtle 98 turtle 167 ) ]
ask turtle 71 [ create-links-with (turtle-set turtle 81 turtle 162 turtle 22 turtle 11 turtle 186 turtle 107 turtle 69 turtle 108 ) ]
ask turtle 105 [ create-links-with (turtle-set turtle 28 turtle 39 turtle 0 turtle 116 turtle 58 turtle 27 turtle 194 turtle 93 turtle 163 turtle 96 turtle 33 turtle 166 turtle 169 ) ]
ask turtle 199 [ create-links-with (turtle-set turtle 112 turtle 152 turtle 56 turtle 63 turtle 168 turtle 132 turtle 23 turtle 131 turtle 137 turtle 176 turtle 25 ) ]
ask turtle 118 [ create-links-with (turtle-set turtle 67 turtle 26 turtle 89 ) ]
ask turtle 4 [ create-links-with (turtle-set turtle 83 turtle 44 turtle 115 turtle 37 turtle 27 ) ]
ask turtle 125 [ create-links-with (turtle-set turtle 84 turtle 152 turtle 52 turtle 9 turtle 10 turtle 120 turtle 22 ) ]
ask turtle 3 [ create-links-with (turtle-set turtle 0 turtle 173 turtle 124 turtle 106 turtle 187 turtle 64 turtle 18 turtle 160 ) ]
ask turtle 165 [ create-links-with (turtle-set turtle 62 turtle 146 turtle 187 turtle 69 turtle 94 turtle 42 turtle 195 turtle 138 turtle 133 turtle 21 turtle 0 ) ]
ask turtle 75 [ create-links-with (turtle-set turtle 14 turtle 59 turtle 55 turtle 51 turtle 131 turtle 148 turtle 163 turtle 52 turtle 106 turtle 54 turtle 194 ) ]
ask turtle 46 [ create-links-with (turtle-set turtle 9 turtle 81 turtle 66 turtle 153 turtle 102 turtle 19 turtle 40 turtle 120 turtle 159 ) ]
ask turtle 138 [ create-links-with (turtle-set turtle 112 turtle 48 turtle 123 turtle 9 turtle 108 turtle 50 turtle 180 turtle 26 turtle 100 turtle 165 turtle 97 turtle 148 turtle 172 turtle 58 ) ]
ask turtle 66 [ create-links-with (turtle-set turtle 114 turtle 159 turtle 46 turtle 44 turtle 53 turtle 33 turtle 93 turtle 18 turtle 58 ) ]
ask turtle 155 [ create-links-with (turtle-set turtle 117 turtle 99 turtle 111 ) ]
ask turtle 196 [ create-links-with (turtle-set turtle 18 turtle 147 turtle 183 turtle 122 turtle 176 turtle 30 turtle 0 turtle 41 turtle 99 turtle 69 turtle 115 turtle 44 turtle 103 turtle 114 ) ]
ask turtle 80 [ create-links-with (turtle-set turtle 97 turtle 173 turtle 133 turtle 101 turtle 194 turtle 147 turtle 18 turtle 38 turtle 130 turtle 74 turtle 65 turtle 113 ) ]
ask turtle 101 [ create-links-with (turtle-set turtle 18 turtle 55 turtle 106 turtle 133 turtle 80 turtle 110 turtle 152 turtle 36 turtle 197 ) ]
ask turtle 28 [ create-links-with (turtle-set turtle 105 turtle 94 turtle 31 turtle 149 turtle 21 turtle 41 turtle 74 ) ]
ask turtle 160 [ create-links-with (turtle-set turtle 188 turtle 106 turtle 172 turtle 77 turtle 184 turtle 3 ) ]
ask turtle 6 [ create-links-with (turtle-set turtle 14 ) ]
ask turtle 35 [ create-links-with (turtle-set turtle 65 turtle 67 turtle 44 turtle 54 ) ]
ask turtle 78 [ create-links-with (turtle-set turtle 171 turtle 42 ) ]
ask turtle 85 [ create-links-with (turtle-set turtle 16 ) ]
ask turtle 98 [ create-links-with (turtle-set turtle 148 turtle 62 turtle 170 turtle 145 turtle 195 ) ]
ask turtle 144 [ create-links-with (turtle-set turtle 148 turtle 14 turtle 81 turtle 57 turtle 51 turtle 64 turtle 179 turtle 150 ) ]
ask turtle 43 [ create-links-with (turtle-set turtle 58 turtle 158 turtle 141 turtle 147 turtle 76 turtle 179 turtle 113 turtle 0 turtle 149 ) ]
ask turtle 188 [ create-links-with (turtle-set turtle 160 turtle 113 turtle 27 turtle 17 turtle 57 turtle 153 turtle 159 turtle 194 turtle 129 ) ]
ask turtle 147 [ create-links-with (turtle-set turtle 172 turtle 19 turtle 18 turtle 196 turtle 80 turtle 43 turtle 164 turtle 198 turtle 32 turtle 158 turtle 127 turtle 161 turtle 159 ) ]
ask turtle 178 [ create-links-with (turtle-set turtle 168 turtle 29 turtle 108 turtle 58 turtle 195 turtle 99 turtle 116 ) ]
ask turtle 9 [ create-links-with (turtle-set turtle 46 turtle 103 turtle 41 turtle 45 turtle 125 turtle 138 turtle 146 turtle 42 turtle 86 turtle 120 turtle 31 ) ]
ask turtle 158 [ create-links-with (turtle-set turtle 43 turtle 62 turtle 122 turtle 147 ) ]
ask turtle 172 [ create-links-with (turtle-set turtle 150 turtle 81 turtle 163 turtle 147 turtle 55 turtle 14 turtle 50 turtle 38 turtle 160 turtle 54 turtle 186 turtle 138 ) ]
ask turtle 69 [ create-links-with (turtle-set turtle 64 turtle 97 turtle 8 turtle 152 turtle 165 turtle 196 turtle 61 turtle 146 turtle 71 turtle 33 turtle 51 ) ]
ask turtle 1 [ create-links-with (turtle-set turtle 157 turtle 7 turtle 142 turtle 197 turtle 30 ) ]
ask turtle 192 [ create-links-with (turtle-set turtle 55 turtle 179 turtle 166 turtle 87 turtle 163 turtle 45 turtle 77 turtle 193 turtle 108 ) ]
ask turtle 132 [ create-links-with (turtle-set turtle 199 ) ]
ask turtle 137 [ create-links-with (turtle-set turtle 131 turtle 54 turtle 31 turtle 5 turtle 117 turtle 195 turtle 199 turtle 112 turtle 197 turtle 106 turtle 53 ) ]
ask turtle 113 [ create-links-with (turtle-set turtle 150 turtle 188 turtle 181 turtle 175 turtle 43 turtle 47 turtle 80 ) ]
ask turtle 110 [ create-links-with (turtle-set turtle 101 turtle 168 turtle 180 turtle 90 ) ]
ask turtle 90 [ create-links-with (turtle-set turtle 49 turtle 8 turtle 44 turtle 42 turtle 111 turtle 110 turtle 97 ) ]
ask turtle 190 [ create-links-with (turtle-set turtle 32 turtle 143 turtle 12 ) ]
ask turtle 67 [ create-links-with (turtle-set turtle 49 turtle 118 turtle 161 turtle 111 turtle 35 turtle 179 turtle 151 turtle 173 turtle 47 turtle 187 turtle 53 ) ]
ask turtle 111 [ create-links-with (turtle-set turtle 134 turtle 51 turtle 67 turtle 90 turtle 155 turtle 129 ) ]
ask turtle 120 [ create-links-with (turtle-set turtle 15 turtle 163 turtle 88 turtle 58 turtle 125 turtle 46 turtle 9 turtle 181 turtle 161 ) ]
ask turtle 167 [ create-links-with (turtle-set turtle 15 turtle 170 turtle 34 turtle 96 turtle 97 turtle 103 turtle 115 ) ]
ask turtle 12 [ create-links-with (turtle-set turtle 38 turtle 65 turtle 99 turtle 51 turtle 41 turtle 52 turtle 177 turtle 95 turtle 148 turtle 190 ) ]
ask turtle 53 [ create-links-with (turtle-set turtle 31 turtle 51 turtle 148 turtle 151 turtle 169 turtle 180 turtle 163 turtle 66 turtle 146 turtle 161 turtle 42 turtle 67 turtle 137 ) ]
ask turtle 157 [ create-links-with (turtle-set turtle 173 turtle 70 turtle 123 turtle 50 turtle 1 turtle 171 turtle 153 turtle 17 turtle 108 turtle 102 turtle 87 ) ]
ask turtle 27 [ create-links-with (turtle-set turtle 95 turtle 51 turtle 188 turtle 185 turtle 105 turtle 109 turtle 36 turtle 131 turtle 4 ) ]
ask turtle 48 [ create-links-with (turtle-set turtle 138 turtle 136 turtle 163 ) ]
ask turtle 29 [ create-links-with (turtle-set turtle 166 turtle 102 turtle 178 turtle 83 turtle 25 turtle 179 turtle 16 turtle 57 ) ]
ask turtle 81 [ create-links-with (turtle-set turtle 71 turtle 123 turtle 172 turtle 144 turtle 46 turtle 104 turtle 37 turtle 173 turtle 56 turtle 97 turtle 149 ) ]
ask turtle 79 [ create-links-with (turtle-set turtle 39 turtle 177 turtle 65 ) ]
ask turtle 18 [ create-links-with (turtle-set turtle 101 turtle 196 turtle 147 turtle 58 turtle 96 turtle 80 turtle 14 turtle 3 turtle 123 turtle 66 turtle 115 ) ]
ask turtle 141 [ create-links-with (turtle-set turtle 99 turtle 43 turtle 58 turtle 5 ) ]
ask turtle 134 [ create-links-with (turtle-set turtle 96 turtle 111 turtle 135 turtle 87 ) ]
ask turtle 14 [ create-links-with (turtle-set turtle 75 turtle 108 turtle 91 turtle 6 turtle 144 turtle 83 turtle 172 turtle 51 turtle 173 turtle 18 turtle 94 ) ]
ask turtle 20 [ create-links-with (turtle-set turtle 193 turtle 143 turtle 62 ) ]
ask turtle 76 [ create-links-with (turtle-set turtle 150 turtle 43 ) ]
ask turtle 109 [ create-links-with (turtle-set turtle 159 turtle 92 turtle 27 turtle 166 ) ]
ask turtle 154 [ create-links-with (turtle-set turtle 93 turtle 115 turtle 123 ) ]
ask turtle 50 [ create-links-with (turtle-set turtle 194 turtle 157 turtle 172 turtle 138 turtle 163 turtle 152 ) ]

end
@#$#@#$#@
GRAPHICS-WINDOW
933
29
1495
612
32
32
8.5
1
10
1
1
1
0
0
0
1
-32
32
-32
32
0
0
1
ticks
30.0

SLIDER
19
25
356
58
num_of_runs
num_of_runs
1
20
5
1
1
NIL
HORIZONTAL

SLIDER
19
59
356
92
max_iterations
max_iterations
10000
100000
50000
100
1
NIL
HORIZONTAL

SLIDER
21
111
438
144
p_broadcast
p_broadcast
0
0.1
0.05
0.001
1
NIL
HORIZONTAL

SLIDER
21
145
438
178
p_update
p_update
0
0.1
0.05
0.001
1
NIL
HORIZONTAL

BUTTON
119
228
189
261
Run All
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
360
60
438
105
Iteration
iteration
0
1
11

BUTTON
292
190
385
223
Display Network
setup-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
388
190
470
250
central_turtle
0
1
0
Number

OUTPUT
638
63
929
611
8

MONITOR
360
13
438
58
Run
runs
17
1
11

BUTTON
22
228
117
261
Setup Runs
setup_runs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
21
266
156
299
show_lexicons
show_lexicons
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
