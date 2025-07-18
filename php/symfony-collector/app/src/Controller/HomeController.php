<?php

namespace App\Controller;

use OpenTelemetry\API\Trace\Span;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class HomeController extends AbstractController
{
    public function index(): Response
    {
        return $this->render('home/index.html.twig', [
            'message' => 'Welcome to Symfony with AppSignal!',
        ]);
    }

    public function slow(): Response
    {
        sleep(3);
        return $this->render('home/slow.html.twig');
    }

    public function error(): Response
    {
        throw new \Exception('Uh oh!');
    }
}
