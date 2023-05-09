return {
  s({trig='frame', snippetType="autosnippet"}, fmt([[
  \begin{frame}<>
    <>
  \end{frame}
  ]], {
    i(1, "Title"), i(2, "Content")
  }, {
    delimiters = "<>"
  })),
  s({trig="tt", dscr="Expands 'tt' to '\\texttt{}'"}, fmt([[
  \texttt{<>}
  ]], {
    i(1, "text")
  }, {
    delimiters = "<>"
  })),
  s({trig='col', snippetType="autosnippet"}, fmt([[
  \begin{column}[<>\textwidth]
    <>
  \end{column}
  ]], {
    i(1, "0.5"), i(2, "column")
  }, {
    delimiters = "<>"
  })),
  s({trig='cols', snippetType="autosnippet"}, fmt([[
  \begin{columns}
    \begin{column}[<>\textwidth]
      <>
    \end{column}
    \begin{column}[<>\textwidth]
      <>
    \end{column}
  \end{columns}
  ]], {
    i(1, "0.5"), i(2, "column1"),
    i(3, "0.5"), i(4, "column2")
  }, {
    delimiters = "<>"
  }))}

