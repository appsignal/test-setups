import {
  Entity,
  Property,
} from '@mikro-orm/core';

import BaseEntity from '@/db/BaseEntity';

@Entity()
export default class BlogPost extends BaseEntity {
  @Property({ columnType: 'text' })
  title!: string;

  @Property({ columnType: 'text' })
  link!: string;

  @Property({ columnType: 'text' })
  content!: string;

  @Property({ columnType: 'text' })
  excerpt!: string;

  @Property({ columnType: 'text', nullable: true })
  image?: string;
}
