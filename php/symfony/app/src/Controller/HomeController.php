<?php

namespace App\Controller;

use App\BadClass;
use Appsignal\Appsignal;
use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Throwable;

class HomeController extends AbstractController
{
    #[Route('/', name: 'home')]
    public function index(): Response
    {
        $params = [
            'param1' => 'value1',
            'param2' => 'value2',
            'nested' => [
                'param3' => 'value3',
                'param4' => 'value4',
            ],
        ];

        Appsignal::addAttributes([
            'appsignal.function.parameters' => json_encode($params),
        ]);

        Appsignal::addAttributes([
            'appsignal.tag.user_id' => 123,
            'appsignal.tag.my_tag_string' => 'tag value',
            'appsignal.tag.my_tag_string_slice' => ['abc', 'def'],
            'appsignal.tag.my_tag_bool_true' => true,
            'appsignal.tag.my_tag_bool_false' => false,
            'appsignal.tag.my_tag_bool_slice' => [true, false],
            'appsignal.tag.my_tag_float64' => 12.34,
            'appsignal.tag.my_tag_float64_slice' => [12.34, 56.78],
            'appsignal.tag.my_tag_int' => 1234,
            'appsignal.tag.my_tag_int_slice' => [1234, 5678],
            'appsignal.tag.my_tag_int64' => 1234,
            'appsignal.tag.my_tag_int64_slice' => [1234, 5678],
        ]);

        return $this->render('home/index.html.twig', [
            'message' => 'Welcome to Symfony with AppSignal!',
        ]);
    }

    #[Route('/slow', name: 'slow')]
    public function slow(): Response
    {
        sleep(3);

        return $this->render('home/slow.html.twig');
    }

    #[Route('/extension', name: 'extension')]
    public function extension(): Response
    {
        $extensionLoaded = extension_loaded('opentelemetry') ? 'yes' : 'no';

        return $this->render('back.html.twig', ['message' => $extensionLoaded]);
    }

    #[Route('/io', name: 'io')]
    public function io(): Response
    {
        $results = [];
        $tempFile = sys_get_temp_dir() . '/temp_io_test.txt';

        // file_put_contents - Write data to file
        $content = 'IO test content - ' . date('Y-m-d H:i:s') . "\n";
        file_put_contents($tempFile, $content);
        $results[] = 'file_put_contents: File written to ' . $tempFile;

        // file_get_contents - Read entire file into string
        $readContent = file_get_contents($tempFile);
        $results[] = 'file_get_contents: Read content - ' . trim($readContent);

        // fopen - Open file for stream operations
        $stream = fopen($tempFile, 'a+');
        $results[] = 'fopen: Opened file stream for ' . $tempFile;

        // fwrite - Write to file stream
        $additionalContent = "Additional line via fwrite\n";
        fwrite($stream, $additionalContent);
        $results[] = 'fwrite: Wrote additional content to stream';

        // fread - Read from file stream
        rewind($stream); // Reset to beginning
        $streamContent = fread($stream, 100);
        $results[] = 'fread: Read from stream - ' . trim($streamContent);

        // Close stream and clean up
        fclose($stream);
        unlink($tempFile);
        $results[] = 'Cleanup: File deleted';

        return $this->render('back.html.twig', [
            'message' => 'OpenTelemetry IO instrumentation test completed',
            'json' => $results,
        ]);
    }

    #[Route('/backtrace', name: 'backtrace')]
    public function backtrace(): Response
    {
        try {
            $this->methodA();
        } catch (\Exception $e) {
            Appsignal::setError($e);

            return $this->render('backtrace.html.twig', [
                'error' => $e->getMessage(),
                'backtrace' => $e->getTraceAsString(),
            ], new Response('', 500));
        }
    }

    #[Route('/instrument', name: 'instrument')]
    public function instrument(): Response
    {
        Appsignal::instrument(
            'my-span',
            [
                'string-attribute' => 'abcdef',
                'int-attribute' => 1234,
                'bool-attribute' => true,
            ],
            function () {}
        );

        return $this->render('back.html.twig', ['message' => 'Added a span to this trace.']);
    }

    #[Route('/instrument-nested', name: 'instrument_nested')]
    public function instrumentNested(): Response
    {
        Appsignal::instrument('parent', ['msg' => 'from parent span'], function () {
            $span = Appsignal::instrument('child', ['msg' => 'from child span']);
            $span->end();
        });

        return $this->render('back.html.twig', ['message' => 'Added nested spans to this trace.']);
    }

    #[Route('/set-action', name: 'set_action')]
    public function setAction(): Response
    {
        Appsignal::setAction('my action');

        return $this->render('back.html.twig', ['message' => 'Set custom action name for this trace.']);
    }

    #[Route('/custom-data', name: 'custom_data')]
    public function customData(): Response
    {
        Appsignal::addAttributes([
            'string-attribute' => 'abcdef',
            'int-attribute' => 1234,
            'bool-attribute' => true,
        ]);

        return $this->render('back.html.twig', ['message' => 'Set custom data for this trace.']);
    }

    #[Route('/tags', name: 'tags')]
    public function tags(): Response
    {
        Appsignal::addTags([
            'string-tag' => 'some value',
            'integer-tag' => 1234,
            'bool-tag' => true,
        ]);

        return $this->render('back.html.twig', ['message' => 'Added tags to this trace.']);
    }

    #[Route('/log', name: 'log')]
    public function log(LoggerInterface $logger): Response
    {
        $logger->info('My log');

        return $this->render('back.html.twig', ['message' => 'Sent a log.']);
    }

    #[Route('/logs', name: 'logs')]
    public function logs(LoggerInterface $logger): Response
    {
        $logger->info('Logging a message');
        $logger->error('Logging an error message');
        $logger->info('Logging a fancy message', ['some' => 'context']);

        return $this->render('back.html.twig', ['message' => 'Sent multiple logs.']);
    }

    #[Route('/log-with-attributes', name: 'log_with_attributes')]
    public function logWithAttributes(LoggerInterface $logger): Response
    {
        $logger->info('My log with attributes', ['foo' => 'bar']);

        return $this->render('back.html.twig', ['message' => 'Sent a log with attributes.']);
    }

    #[Route('/set-gauge', name: 'set_gauge')]
    public function setGauge(): Response
    {
        Appsignal::setGauge('my_gauge', 12);
        Appsignal::setGauge('my_gauge_with_attributes', 13, ['region' => 'eu']);

        return $this->render('back.html.twig', ['message' => 'Set a gauge with and without attributes.']);
    }

    #[Route('/add-distribution-value', name: 'add_distribution_value')]
    public function addDistributionValue(): Response
    {
        Appsignal::addDistributionValue('memory_usage', 50);
        Appsignal::addDistributionValue('memory_usage', 70);

        Appsignal::addDistributionValue('with_attributes', 10, ['region' => 'eu']);
        Appsignal::addDistributionValue('with_attributes', 20, ['region' => 'eu']);
        Appsignal::addDistributionValue('with_attributes', 30, ['region' => 'eu']);

        return $this->render('back.html.twig', ['message' => 'Added values to a distribution with and without attributes.']);
    }

    #[Route('/counter', name: 'counter')]
    public function counter(): Response
    {
        Appsignal::incrementCounter('my_counter', 1);
        Appsignal::incrementCounter('my_counter', 3, ['region' => 'eu']);

        return $this->render('back.html.twig', ['message' => 'Incremented counter with and without attributes.']);
    }

    #[Route('/error', name: 'error')]
    public function error(Request $request): Response
    {
        if ($request->query->get('debug') == 'true') {
            try {
                BadClass::throw();
            } catch (Throwable $e) {
                return $this->render('backtrace.html.twig', [
                    'error' => $e->getMessage(),
                    'backtrace' => $e->getTraceAsString(),
                ], new Response('', 500));
            }
        }

        BadClass::throw();
    }

    #[Route('/error-wrapped', name: 'error_wrapped')]
    public function errorWrapped(Request $request): Response
    {
        if ($request->query->get('debug') == 'true') {
            try {
                BadClass::throwWrapped();
            } catch (Throwable $e) {
                return $this->render('backtrace.html.twig', [
                    'error' => $e->getMessage(),
                    'backtrace' => $e->getTraceAsString(),
                ], new Response('', 500));
            }
        }

        BadClass::throwWrapped();
    }

    #[Route('/error-handled', name: 'error_handled')]
    public function errorHandled(): Response
    {
        try {
            BadClass::throwWrapped();
        } catch (Throwable $e) {
            Appsignal::setError($e);
        }

        return $this->render('back.html.twig', ['message' => 'Reported handled error to AppSignal']);
    }

    private function methodA()
    {
        usleep(50000); // 50ms delay
        return $this->methodB();
    }

    private function methodB()
    {
        usleep(30000); // 30ms delay
        return $this->methodC();
    }

    private function methodC()
    {
        usleep(20000); // 20ms delay
        return $this->methodD();
    }

    private function methodD()
    {
        usleep(10000); // 10ms delay
        return $this->methodE();
    }

    private function methodE()
    {
        usleep(5000); // 5ms delay
        return $this->methodF();
    }

    private function methodF()
    {
        return $this->throwError();
    }

    private function throwError()
    {
        throw new \Exception('Deep stack trace error from methodF -> throwError');
    }
}
