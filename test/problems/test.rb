def test_problem
  {
    types: [:email, :role, :string, :blog_id],
    objects: [[:'tom@tom.com', :email], [:bloger, :role],
              [:hello, :string], [:world, :string], [:b1, :blog_id]],
    init: [],
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
        parameters: [[:x, :role], [:y, :email]],
        precond: [],
        effect: [
          [:user, :y],
          [:user_role, :y, :x],
          [:login, :y]
        ]
      },
      {
        name: :login,
        parameters: [[:x, :email]],
        precond: [[:user, :x], [:-, :login, :x]],
        effect: [[:login, :x]]
      },
      {
        name: :logout,
        parameters: [[:x, :email]],
        precond: [[:user, :x], [:login, :x]],
        effect: [[:-, :login, :x]]
      },
      {
        name: :post,
        parameters: [[:u, :email], [:z1, :blog_id],
                     [:z2, :string], [:z3, :string]],
        precond: [
          [:user, :u],
          [:login, :u],
          [:user_role, :u, :bloger]
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
