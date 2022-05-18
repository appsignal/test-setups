import {
  PrimaryKey,
  Property,
} from '@mikro-orm/core';
import { v4 } from 'uuid';

export default abstract class BaseEntity {
  @PrimaryKey({ columnType: 'uuid' })
  id: string = v4();

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
