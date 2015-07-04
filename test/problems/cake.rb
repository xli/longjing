def cake_problem
  {
    objects: [:cake],
    init: [[:have, :cake]],
    goal: [[:have, :cake], [:eaten, :cake]],
    actions: [
      {
        name: :eat,
        precond: [[:have, :cake]],
        effect: [[:-, :have, :cake], [:eaten, :cake]]
      },
      {
        name: :bake,
        precond: [[:-, :have, :cake]],
        effect: [[:have, :cake]]
      }
    ],
    solution: [[:eat], [:bake]]
  }
end
