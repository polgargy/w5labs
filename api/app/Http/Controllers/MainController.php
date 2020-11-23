<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MainController extends Controller
{
    public function getResult(Request $request)
    {
        $string      = strtolower($request->string);
        $words       = str_word_count($string, 1);
        $uniqueWords = array_unique($words);
        sort($uniqueWords);
        
        $primeFactor   = $this->getPrimeFactor(count($uniqueWords));
        $canonicalForm = implode('*', $primeFactor);
        

        return response()->json([
            'canonical_form' => $canonicalForm,
            'unique_words'   => $uniqueWords,
        ]);
    }

    protected function getPrimeFactor($num)
    {
        $sqrt = sqrt($num);
        for ($i = 2; $i <= $sqrt; $i++) {
            if ($num % $i === 0) {
                return array_merge($this->getPrimeFactor($num / $i), array($i));
            }
        }
        return array($num);
    }
}
