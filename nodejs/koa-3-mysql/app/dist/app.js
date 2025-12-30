"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const koa_1 = tslib_1.__importDefault(require("koa"));
const router_1 = tslib_1.__importDefault(require("@koa/router"));
const koa_bodyparser_1 = tslib_1.__importDefault(require("koa-bodyparser"));
const mysql_1 = tslib_1.__importDefault(require("mysql"));
const mysql2_1 = tslib_1.__importDefault(require("mysql2"));
const mysqlConfig = {
    host: "mysql",
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
};
const app = new koa_1.default();
const router = new router_1.default();
const port = process.env.PORT;
app.use((0, koa_bodyparser_1.default)());
router.get("/", async (ctx) => {
    ctx.body = "GET query received!";
});
router.get("/error", async (_ctx) => {
    throw new Error("Expected test error!");
});
router.get("/slow", async (ctx) => {
    await new Promise((resolve) => setTimeout(resolve, 3000));
    ctx.body = "Well, that took forever!";
});
router.get("/mysql-query", async (ctx) => {
    await dummyQuery(mysql_1.default);
    ctx.body = "MySQL query received!";
});
router.get("/mysql2-query", async (ctx) => {
    await dummyQuery(mysql2_1.default);
    ctx.body = "MySQL2 query received!";
});
function dummyQuery(mysqlClient) {
    let connection;
    return new Promise((resolve, reject) => {
        connection = mysqlClient.createConnection(mysqlConfig);
        connection.connect();
        connection.query("SELECT 1 + 1 AS solution", (err, rows, fields) => {
            if (err)
                reject(err);
            console.log({ err, rows, fields });
            resolve(rows[0].solution);
        });
    }).finally(() => connection.end());
}
app.use(router.routes()).use(router.allowedMethods());
app.listen(port);
console.log(`Example app listening on port ${port}`);
