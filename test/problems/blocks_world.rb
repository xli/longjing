def blocks_world_problem
  {
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
        arguments: [:b, :x, :y],
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
        arguments: [:b, :x],
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
    ]
  }
end
