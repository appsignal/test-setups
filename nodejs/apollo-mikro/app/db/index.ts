import { MikroORM } from '@mikro-orm/core';
import type { Options, Configuration } from '@mikro-orm/core';
import type { EntityManager, PostgreSqlDriver } from '@mikro-orm/postgresql';
import _ from 'lodash';

import BlogPost from '@/db/BlogPost';

const {
  DB_NAME,
  DB_USER,
  DB_PASSWORD,
  DB_HOST,
  DB_PORT,
} = process.env;

const mikroOrmConfig: Options<PostgreSqlDriver> | Configuration<PostgreSqlDriver> = {
  type: 'postgresql',
  dbName: DB_NAME,
  user: DB_USER,
  password: DB_PASSWORD,
  host: DB_HOST,
  port: _.toNumber(DB_PORT),
  entities: [
    BlogPost,
  ],
};

const db = {} as {
  orm: MikroORM<PostgreSqlDriver>;
  em: EntityManager<PostgreSqlDriver>;
};

export const initialize = async (): Promise<void> => {
  db.orm = await MikroORM.init<PostgreSqlDriver>(mikroOrmConfig);

  db.em = db.orm.em;
};

export default db;
