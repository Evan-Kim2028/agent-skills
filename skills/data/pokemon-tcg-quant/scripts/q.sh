#!/bin/bash
B64=$(base64 -w0)
ssh lake-vps "ssh lor-main \"echo $B64 | base64 -d > /tmp/agent_q.sql && cd ~/data/pokemontcg_pipe/gold && ~/lake-of-rage/.venv/bin/python -c \\\"
import duckdb
con=duckdb.connect()
sql=open('/tmp/agent_q.sql').read()
for stmt in [s for s in sql.split(';;') if s.strip()]:
    try:
        r=con.execute(stmt)
        cols=[d[0] for d in r.description]
        rows=r.fetchall()
        print(' | '.join(cols))
        print('-'*80)
        for row in rows:
            print(' | '.join('' if v is None else str(v)[:55] for v in row))
        print('(%d rows)' % len(rows))
    except Exception as e:
        print('ERROR:', e)
    print()
\\\"\""
