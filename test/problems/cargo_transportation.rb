def cargo_transportation_problem
  {
    init: [
      [:at, :c1, :sfo],
      [:at, :c2, :jfk],
      [:at, :p1, :sfo],
      [:at, :p2, :jfk],
      [:cargo, :c1],
      [:cargo, :c2],
      [:plane, :p1],
      [:plane, :p2],
      [:airport, :sfo],
      [:airport, :jfk]
    ],
    goal: [
      [:at, :c1, :jfk],
      [:at, :c2, :sfo]
    ],
    solution: [
      [:load, :c1, :p1, :sfo],
      [:fly, :p1, :sfo, :jfk],
      [:unload, :c1, :p1, :jfk],
      [:load, :c2, :p2, :jfk],
      [:fly, :p2, :jfk, :sfo],
      [:unload, :c2, :p2, :sfo]
    ],
    actions: [
      {
        name: :load,
        arguments: [:c, :p, :a],
        precond: [
          [:at, :c, :a],
          [:at, :p, :a],
          [:cargo, :c],
          [:plane, :p],
          [:airport, :a]
        ],
        effect: [
          [:-, :at, :c, :a],
          [:in, :c, :p]
        ]
      },
      {
        name: :unload,
        arguments: [:c, :p, :a],
        precond: [
          [:in, :c, :p],
          [:at, :p, :a],
          [:cargo, :c],
          [:plane, :p],
          [:airport, :a]
        ],
        effect: [
          [:at, :c, :a],
          [:-, :in, :c, :p]
        ]
      },
      {
        name: :fly,
        arguments: [:p, :from, :to],
        precond: [
          [:at, :p, :from],
          [:plane, :p],
          [:airport, :from],
          [:airport, :to]
        ],
        effect: [
          [:-, :at, :p, :from],
          [:at, :p, :to]
        ]
      }
    ]
  }
end
