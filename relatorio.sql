WITH valoremaberto AS (
  SELECT
    id_clientepreferencial,
    SUM(valor + valormulta + valorjuros) aberto
  FROM
    recebercreditorotativo rcr
  WHERE
    id_situacaorecebercreditorotativo = 0
  GROUP BY
    id_clientepreferencial
),
baixaparcial AS (
  SELECT
    rcr.id_clientepreferencial,
    SUM(rcri.valor) baixa
  FROM
    recebercreditorotativoitem rcri
    INNER JOIN recebercreditorotativo rcr ON rcri.id_recebercreditorotativo = rcr.id
  WHERE
    rcr.id_situacaorecebercreditorotativo = 0
  GROUP BY
    rcr.id_clientepreferencial
  ORDER BY
    rcr.id_clientepreferencial
)
SELECT DISTINCT
  c.id,
  c.nome,
  c.cnpj,
  c.email,
  c.telefone,
  CASE WHEN va.aberto - bp.baixa IS null
  THEN va.aberto 
  ELSE va.aberto - bp.baixa END AS "valor aberto"
FROM
  clientepreferencial c
  INNER JOIN recebercreditorotativo rcr ON rcr.id_clientepreferencial = c.id
  INNER JOIN recebercreditorotativoitem rcri ON rcri.id_recebercreditorotativo = rcr.id
  INNER JOIN valoremaberto va ON c.id = va.id_clientepreferencial
  LEFT JOIN baixaparcial bp ON c.id = bp.id_clientepreferencial
GROUP BY
  c.id,
  c.nome,
  c.cnpj,
  c.email,
  c.telefone,
  va.aberto,
  bp.baixa,
  rcr.valorjuros,
  rcr.valormulta,
  rcri.valor
ORDER BY
  c.id

