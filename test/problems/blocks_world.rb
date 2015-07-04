def blocks_world_problem
  {
    objects: [:A, :B, :C, :table],
    init: [[:on, :A, :table],
           [:on, :B, :table],
           [:on, :C, :A],
           [:block, :A],
           [:block, :B],
           [:block, :C],
           [:clear, :B],
           [:clear, :C]],
    goal: [[:on, :A, :B], [:on, :B, :C]],
    actions: [
      {
        name: :move,
        parameters: [:b, :x, :y],
        precond: [[:on, :b, :x],
                  [:clear, :b],
                  [:clear, :y],
                  [:block, :b],
                  [:block, :y],
                  [:!=, :b, :x],
                  [:!=, :b, :y],
                  [:!=, :x, :y]],
        effect: [
          [:on, :b, :y],
          [:clear, :x],
          [:-, :on, :b, :x],
          [:-, :clear, :y]
        ]
      },
      {
        name: :moveToTable,
        parameters: [:b, :x],
        precond: [[:on, :b, :x],
                  [:block, :b],
                  [:clear, :b],
                  [:!=, :b, :x]],
        effect: [
          [:on, :b, :table],
          [:clear, :x],
          [:-, :on, :b, :x]
        ]
      }
    ],
    solution: [[:moveToTable, :C, :A],
               [:move, :B, :table, :C],
               [:move, :A, :table, :B]]
  }
end
