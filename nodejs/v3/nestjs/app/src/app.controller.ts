import { Controller, Get } from "@nestjs/common"
import { AppService } from "./app.service"

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello()
  }

  @Get("/error")
  getError(): string {
    throw new Error("Expected test error")
  }

  @Get("/slow")
  async getSlow(): Promise<string> {
    await new Promise(resolve => setTimeout(resolve, 3000))

    return "Well, that took forever!"
  }
}
