(define (problem freecell-f2-c2-s2-i1-02-12
)(:domain freecell)
(:objects
          c0 ca c2
          h0 ha h2
 - card
          celln0 celln1 celln2
 - cellnum
          coln0 coln1 coln2
 - colnum
          n0 n1 n2
 - num
           c h
 - suit
)
(:init
(value c0 n0)
(value ca n1)
(value c2 n2)
(value h0 n0)
(value ha n1)
(value h2 n2)
(cellsuccessor celln1 celln0)
(cellsuccessor celln2 celln1)
(colsuccessor coln1 coln0)
(colsuccessor coln2 coln1)
(successor n1 n0)
(successor n2 n1)
(suit c0 c)
(suit ca c)
(suit c2 c)
(suit h0 h)
(suit ha h)
(suit h2 h)
(home c0)
(home h0)
(cellspace celln2)
(colspace coln1)

(bottomcol c2)
(on ha c2)
(on ca ha)
(on h2 ca)
(clear h2)
)
(:goal
(and
(home c2)
(home h2)
)
)
)
