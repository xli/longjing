def test_problem
  {
    init: [
      [:email, :'tom@tom.com'],
      [:role, :bloger],
      [:string, :hello],
      [:string, :world],
      [:blog_id, :b1]
    ],
    goal: [[:blog, :b1],
           [:title, :b1, :hello],
           [:body, :b1, :world],
           [:author, :b1, :'tom@tom.com'],
           [:-, :login, :'tom@tom.com']],
    solution: [[:register, :bloger, :'tom@tom.com'],
               [:post, :'tom@tom.com', :b1, :hello, :world],
               [:logout, :'tom@tom.com']],
    actions: [
      {
        name: :register,
        parameters: [:x, :y],
        precond: [
          [:role, :x],
          [:email, :y]
        ],
        effect: [
          [:user, :y],
          [:user_role, :y, :x],
          [:login, :y]
        ]
      },
      {
        name: :login,
        parameters: [:x],
        precond: [[:user, :x], [:-, :login, :x]],
        effect: [[:login, :x]]
      },
      {
        name: :logout,
        parameters: [:x],
        precond: [[:user, :x], [:login, :x]],
        effect: [[:-, :login, :x]]
      },
      {
        name: :post,
        parameters: [:u, :z1, :z2, :z3],
        precond: [
          [:user, :u],
          [:login, :u],
          [:user_role, :u, :bloger],
          [:blog_id, :z1],
          [:string, :z2],
          [:string, :z3]
        ],
        effect: [
          [:blog, :z1],
          [:title, :z1, :z2],
          [:body, :z1, :z3],
          [:author, :z1, :u],
          [:-, :blog_id, :z1]
        ]
      }
    ]
  }
end
