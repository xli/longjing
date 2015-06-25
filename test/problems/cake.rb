def cake_problem
  {
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
    ]
  }
end
